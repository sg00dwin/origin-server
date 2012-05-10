require 'parseconfig'
require 'pp'
require 'aws'

module OpenShift
  module Amazon
    def setup_rsa_key
      unless File.exists?(RSA)
        log.info "Setting up RSA key..."
        libra_key = File.expand_path("../../../../misc/libra.pem", File.expand_path(__FILE__))
        log.info "Key location = " + libra_key
        log.info "Destination = " + RSA
        FileUtils.mkdir_p File.dirname(RSA)
        FileUtils.chmod 0700, File.dirname(RSA)
        FileUtils.cp libra_key, RSA
        FileUtils.chmod 0600, RSA
      end
    end

    def connect(region=nil)
      conn = nil
      begin
        # Parse the credentials
        config = ParseConfig.new(File.expand_path("~/.awscred"))

        # Setup the SSH key
        setup_rsa_key

        # Setup the global access configuration
        AWS.config(
          :access_key_id => config.get_value("AWSAccessKeyId"),
          :secret_access_key => config.get_value("AWSSecretKey"),
          :ssl_ca_file => "/etc/pki/tls/certs/ca-bundle.trust.crt"
        )

        # Return the AMZ connection
        conn = AWS::EC2.new
      rescue StandardError => e
        puts <<-eos
          Couldn't access credentials in ~/.awscred

          Please create a file with the following format:
            AWSAccessKeyId=<ACCESS_KEY>
            AWSSecretKey=<SECRET_KEY>
        eos
        puts e
        raise "Error - no credentials"
      end
          
      conn = conn.regions[region] if region
      conn
    end

    def check_update
      yum_output = `yum check-update rhc-*`

      packages = {}
      yum_output.split("\n").each do |line|
        if line.start_with?("Obsoleting")
          break
        elsif line.start_with?("rhc")
          pkg_name = line.split[0]
          version = line.split[1]
          packages[pkg_name] = version
        end
      end

      packages
    end

    def get_amis(conn, filter = DEVENV_WILDCARD)
      conn.images.with_owner(:self).
        filter("state", "available").
        filter("name", filter)
    end
    
    def get_specific_ami(conn, filter_val)
      if filter_val.start_with?("ami")
        filter_param = "image-id"
      else
        filter_param = "name"
      end 
      AWS.memoize do
        devenv_amis = conn.images.with_owner(:self).
          filter("state", "available").
          filter(filter_param, filter_val)
        # Take the last DevEnv AMI - memoize saves a remote call
        devenv_amis.to_a[0]

      end
    end

    def get_latest_ami(conn, filter_val = DEVENV_WILDCARD)
      AWS.memoize do
        # Limit to DevEnv images
        devenv_amis = conn.images.with_owner(:self).
          filter("state", "available").
          filter("name", filter_val)
        # Take the last DevEnv AMI - memoize saves a remote call
        devenv_amis.to_a.sort_by {|ami| ami.name.split("_")[1].to_i}.last
      end
    end

    def instance_status(instance)
      (1..10).each do |index|
        begin
          status = instance.status
          return status
        rescue Exception => e
          if index == 10
            instance.terminate
            raise
          end
          log.info "Error getting status(retrying): #{e.message}"
          sleep 30
        end
      end
    end

    def find_instance(conn, name, use_tag=false)
      if use_tag
        instances = conn.instances.filter('tag-key', 'Name').filter('tag-value', name)
      else
        instances = conn.instances.filter('dns-name', name)
      end
      instances.each do |i|
        if (instance_status(i) != :terminated)
          puts "Found instance #{i.id}"
          block_until_available(i)
          return i
        end
      end

      return nil
    end
      
    def terminate_instance(instance, handle_authdenied=false)
      begin
        (0..4).each do
          instance.terminate
          (0..12).each do
            break if instance_status(instance) == :terminated
            log.info "Instance isn't terminated yet... waiting"
            sleep 5
          end
          break if instance_status(instance) == :terminated
          log.info "Instance isn't terminated yet... retrying"
        end
      rescue AWS::EC2::Errors::UnauthorizedOperation
        raise unless handle_authdenied
        log.info "You do not have permission to terminate instances."
      ensure
        if instance_status(instance) != :terminated
          log.info "Failed to terminate.  Calling stop instead."
          add_tag(instance, 'terminate')
          begin
            instance.stop
          rescue Exception => e
            log.info "Failed to stop: #{e.message}"
          end
        end
      end
    end
        
    def add_tag(instance, name, retries=2)
      (1..retries).each do |i|
        begin
          # Tag the instance
          instance.add_tag('Name', :value => name)
        rescue Exception => e
          log.info "Failed adding tag: #{e.message}"
          raise if i == retries
          sleep 5
        end
      end
    end

    def launch_instance(image, name, max_retries = 1)
      log.info "Creating new instance..."

      # You may have to retry creating instances since Amazon
      # fails at bringing them up every once in a while
      retries = 0

      # Launch a new instance
      instance = image.run_instance($amz_options)

      begin
          
        add_tag(instance, name, 10)

        # Block until the instance is accessible
        block_until_available(instance)

        return instance
      rescue ScriptError => e
        # Handles retrying instance creation for instances that
        # didn't come up with SSH access in time
        if retries <= max_retries
          log.info "Retrying instance creation (attempt #{retries + 1})..."

          # Terminate the current instance since it didn't load
          terminate_instance(instance)

          # Launch a new instance
          instance = image.run_instance($amz_options)

          # Retry the above logic to verify accessibility
          retries += 1
          retry
        else
          puts e.message
          exit 1
        end
      end
    end

    def block_until_available(instance)
      log.info "Waiting for instance to be available..."
      
      (0..12).each do
        break if instance_status(instance) == :running
        log.info "Instance isn't running yet... retrying"
        sleep 5
      end

      unless instance_status(instance) == :running
        terminate_instance(instance)
        raise ScriptError, "Timed out before instance was 'running'"
      end

      hostname = instance.dns_name
      (1..30).each do
        break if can_ssh?(hostname)
        log.info "SSH access failed... retrying"
        sleep 5
      end

      unless can_ssh?(hostname)
        terminate_instance(instance)
        raise ScriptError, "SSH availability timed out"
      end

      log.info "Instance (#{hostname}) is accessible"
    end

    def is_valid?(hostname)
      @validation_output = ssh(hostname, '/usr/bin/rhc-accept-node')
      log.info "Node Acceptance Output = #{@validation_output}"
      @validation_output == "PASS"
    end

    def get_private_ip(hostname)
      private_ip = ssh(hostname, "facter ipaddress")
      if !private_ip or private_ip.strip.empty?
        puts "EXITING - AMZ instance didn't return ipaddress fact"
        exit 0
      end
      private_ip
    end
    
    def use_private_ip(hostname)
      private_ip = get_private_ip(hostname)
      puts "Updating instance facts with private ip #{private_ip}"
      set_instance_ip(hostname, private_ip, private_ip)
    end

    def use_public_ip(hostname)
      dhostname = ssh(hostname, "wget -qO- http://169.254.169.254/latest/meta-data/public-hostname")
      public_ip = ssh(hostname, "wget -qO- http://169.254.169.254/latest/meta-data/public-ipv4")
      puts "Updating instance facts with public ip #{public_ip} and hostname #{dhostname}"
      set_instance_ip(hostname, public_ip, dhostname)
    end

    def get_internal_hostname(hostname)
      internal_hostname = ssh(hostname, "hostname")
      internal_hostname
    end

    def update_facts(hostname)
      puts "Updating instance facts and running libra-data to set the public ip..."
      ssh(hostname, "sed -i \"s/.*PUBLIC_IP_OVERRIDE.*/#PUBLIC_IP_OVERRIDE=/g\" /etc/stickshift/stickshift-node.conf; sed -i \"s/.*PUBLIC_HOSTNAME_OVERRIDE.*/#PUBLIC_HOSTNAME_OVERRIDE=/g\" /etc/stickshift/stickshift-node.conf; /usr/libexec/mcollective/update_yaml.rb > /etc/mcollective/facts.yaml; service libra-data start")
      puts 'Done'
    end
    
    def set_instance_ip(hostname, ip, dhostname)
      print "Updating the controller to use the ip '#{ip}'..."
      # Both calls below are needed to fix a race condition between ssh and libra-data start times
      ssh(hostname, "sed -i \"s/.*PUBLIC_IP_OVERRIDE.*/PUBLIC_IP_OVERRIDE='#{ip}'/g\" /etc/stickshift/stickshift-node.conf; sed -i \"s/.*PUBLIC_HOSTNAME_OVERRIDE.*/PUBLIC_HOSTNAME_OVERRIDE='#{dhostname}'/g\" /etc/stickshift/stickshift-node.conf; /usr/libexec/mcollective/update_yaml.rb > /etc/mcollective/facts.yaml")
      puts 'Done'
    end

    def verify_image(image)
      log.info "Tagging image (#{image.id}) as '#{VERIFIED_TAG}'..."
      image.add_tag('Name', :value => VERIFIED_TAG)
      log.info "Done"
    end
    
    def register_image(conn, instance, name, manifest)
      print "Registering AMI..."
      outer_num_retries = 4
      image = nil
      (1..outer_num_retries).each do |outer_index|
        image = conn.images.create(:instance_id => instance.id, 
          :name => name,
          :description => manifest)
        num_retries = 10
        (1..num_retries).each do |index|
          begin
            sleep 30 until image.state == :available
            puts "Sleeping for 30 seconds to let image stabilize..."
            sleep 30
            break
          rescue Exception => e
            raise if index == num_retries && outer_index == outer_num_retries
            if index == num_retries
              log.info "Error getting state: #{e.message}"
              log.info "Deregistering image: #{image.name}"
              image.deregister
              image = nil
            else
              log.info "Error getting state(retrying): #{e.message}"
            end
            sleep 30
          end
        end
        break if image
      end
      puts "Done"
      image
    end

    def terminate_flagged_instances(conn)
      AWS.memoize do
        conn.instances.each do |i|
          if ((instance_status(i) == :stopped) || (instance_status(i) == :running)) && (i.tags["Name"] =~ TERMINATE_REGEX)
            log.info "Terminating #{i.id} - #{i.tags["Name"]}"
            terminate_instance(i)
          end
        end
      end
    end
    
    def terminate_old_verifiers(conn)
      AWS.memoize do
        build_name_to_verifiers = {}
        conn.instances.each do |i|
          VERIFIER_REGEXS.each do |regex|
            if i.tags["Name"] =~ regex
              build_name = $1
              build_num = $2
              build_name_to_verifiers[build_name] = [] unless build_name_to_verifiers[build_name]
              build_name_to_verifiers[build_name] << [build_num, i]
            end
          end
        end
        build_name_to_verifiers.each do |build_name, verifiers|
          unless verifiers.empty?
            verifiers.sort!
            verifiers.each_with_index do |verifier, index|
              build_num = verifier[0]
              i = verifier[1]
              if index == verifiers.length - 1
                unless Time.new - i.launch_time > 16200 #4.5 hours
                  break
                end
              end
              if instance_status(i) == :running || instance_status(i) == :stopped
                log.info "Terminating verifier #{i.id} - #{i.tags["Name"]}"
                terminate_instance(i)
              end
            end
          end
        end
      end
    end
    
    def terminate_old_qe_verifiers(conn)
      AWS.memoize do
        conn.instances.each do |i|
          QE_VERIFIER_REGEXS.each do |regex|
            if i.tags["Name"] =~ regex
              if (instance_status(i) == :running || instance_status(i) == :stopped) && (Time.new - i.launch_time > 43200) #12 hours
                log.info "Terminating verifier #{i.id} - #{i.tags["Name"]}"
                terminate_instance(i)
              end
            end
          end
        end
      end
    end
    
    def flag_old_devenvs(conn)
      AWS.memoize do
        conn.instances.each do |i|
          if (instance_status(i) == :stopped) && !(i.tags["Name"] =~ /preserve/)
            launch_yday = i.launch_time.yday
            yday = Time.new.yday
            if yday < launch_yday
              yday += 365 # minor leap year bug here (will terminate 1 day late)
            end
            if yday - launch_yday > 6
              # Tag the node to give people a heads up
              log.info "Tagging old instances to terminate #{i.tags["Name"]}"
              add_tag(i, 'will-terminate')
            end
          end
        end
      end
    end
    
    def flag_old_qe_devenvs(conn)
      AWS.memoize do
        conn.instances.each do |i|
          current_time = Time.new
          if i.tags["Name"] =~ /^QE_/ && !(i.tags["Name"] =~ /preserve/)
            if ((current_time - i.launch_time) > 43200) && current_time.hour > 13 && (instance_status(i) == :running)
              log.info "Stopping qe instance #{i.id}"
              i.stop
            elsif ((current_time - i.launch_time) > 100800) && (instance_status(i) == :stopped)
              # Tag the node to give people a heads up
              log.info "Tagging qe instance to terminate #{i.tags["Name"]}"
              add_tag(i, 'will-terminate')
            end
          end
        end
      end
    end

    def stop_untagged_instances(conn)
      AWS.memoize do
        conn.instances.each do |i|
          if (instance_status(i) == :running || instance_status(i) == :stopped) && (i.tags['Name'] == nil)
            # Tag the node to give people a heads up
            add_tag(i, 'will-terminate')

            # Stop the nodes to save resources
            log.info "Stopping untagged instance #{i.id}"
            i.stop
          end
        end
      end
    end
  end
end
