begin
  require 'parseconfig'
  require 'fileutils'
  require 'aws'
  require 'right_http_connection'
  require 'net/smtp'
  require 'pp'

  namespace :ami do
    #
    # Global definitions
    #
    AMI = "ami-6a897e03"
    TYPE = "m1.large"
    KEY_PAIR = "libra"
    OPTIONS = {:key_name => KEY_PAIR, :instance_type => TYPE}
    VERSION_REGEX = /li-\d+\.\d+\.?\d*-\d+/
    AMI_REGEX = /li-\d+\.\d+/
    BUILD_REGEX = /^builder-li-\d+\.\d+/
    PREFIX = ENV['LIBRA_DEV'] ? ENV['LIBRA_DEV'] + "-" : ""
    VERIFIER_REGEX = /^#{PREFIX}verifier-li-\d+\.\d+/
    VERIFIED_TAG = "qe-ready"
    BREW_LI = "https://brewweb.devel.redhat.com/packageinfo?packageID=31345"
    GIT_REPO_PUPPET = "ssh://puppet1.ops.rhcloud.com/srv/git/puppet.git"
    CONTENT_TREE = {'puppet' => '/etc/puppet'}
    RSA = File.expand_path("~/.ssh/libra.pem")
    SSH = "ssh 2> /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -i " + RSA
    SCP = "scp 2> /dev/null -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -i " + RSA

    # Force synchronous stdout
    STDOUT.sync, STDERR.sync = true

    # This will verify the Amazon SSL connection
    Rightscale::HttpConnection.params[:ca_file] = "/etc/pki/tls/certs/ca-bundle.trust.crt"

    #
    # Helper method definitions
    #
    def conn
      Aws::Ec2.new(@access_key, @secret_key, params = {:logger => Logger.new('/dev/null')})
    end

    def terminate(instance)
        @conn.terminate_instances([instance])
    end

    def reboot(instance)
        @conn.reboot_instances([instance])
    end

    def instance_value(key)
      conn.describe_instances([@instance])[0][key]
    end

    # Blocks until the current instance is available
    def instance_available
        # Wait until the AWS state is running
        until instance_value(:aws_state) == "running"
          sleep 5
        end

        @dns = instance_value(:dns_name)
        @server = "root@" + @dns

        # Block until we can SSH to the instance
        until `#{SSH} #{@server} 'echo Success'`.split[-1] == "Success"
          sleep 5
        end
    end

    def send_verified_email(version, ami)
        msg = <<END_OF_MESSAGE
From: Libra Jenkins <libra-express@redhat.com>
To: Libra Express <libra-express@redhat.com>
Subject: Build #{version} QE Ready

The build #{version} (AMI #{ami}) is ready for QE.
END_OF_MESSAGE

        Net::SMTP.start('localhost') do |smtp|
          smtp.send_message msg, "libra-express@redhat.com", "libra-express@redhat.com"
        end
    end

    # Ensure AMZ and RSA credentials exist
    task :creds do
      begin
        config = ParseConfig.new(File.expand_path("~/.awscred"))
        @access_key = config.get_value("AWSAccessKeyId")
        @secret_key = config.get_value("AWSSecretKey")
      rescue StandardError => e
        puts e
        msg = <<-eos
          Couldn't access credentials in ~/.awscred

          Please create a file with the following format:
            AWSAccessKeyId=<ACCESS_KEY>
            AWSSecretKey=<SECRET_KEY>
        eos
        exit 1
      end

      unless File.exists?(RSA)
        print "Setting up RSA key..."
        libra_key = File.expand_path("../../misc/libra.pem", File.expand_path(__FILE__))
        FileUtils.cp(libra_key, RSA)
        FileUtils.chmod 0600, RSA
        puts "Done"
      end
    end

    # Ensure we can parse the current version
    task :version do
      yum_output = `yum info li`
      p = $?

      if p.exitstatus != 0
        puts "WARNING - yum error getting li info, cleaning metadata and trying again"
        `yum clean metadata`
        yum_output = `yum info li`
        p = $?
        if p.exitstatus != 0
          puts "EXITING - Error cleaning yum state"
          exit 0
        end
      end

      # Process the yum output to get a version
      version = yum_output.split("\n").collect do |line|
        line.split(":")[1].strip if line.start_with?("Version")
      end.compact[-1]

      # Process the yum output to get a release
      release = yum_output.split("\n").collect do |line|
        line.split(":")[1].strip if line.start_with?("Release")
      end.compact[-1]

      @version = "li-#{version}-#{release.split('.')[0]}"

      raise "Invalid version format" unless @version =~ VERSION_REGEX

      puts "Current version: #{@version}"
    end

    # Grouping of common prereqs
    task :prereqs => [:creds, :version]

    # Tasks dealing with building new AMIs
    namespace :builder do
      desc "Remove any running builders"
      task :clean => ["ami:prereqs"] do
        # Terminate any tagged instances
        instances = conn.describe_instances.collect do |i|
          if (i[:aws_state] == "running") and (i[:tags]["Name"] =~ BUILD_REGEX)
            i[:aws_instance_id]
          end
        end.compact

        conn.terminate_instances(instances) unless instances.empty?
      end

      task :find => ["ami:prereqs"] do
        print "Finding builder instance..."

        # Look up any tagged instances
        instances = conn.describe_instances.map do |i|
          if (i[:aws_state] == "running") and (i[:tags]["Name"] =~ BUILD_REGEX)
            i[:aws_instance_id]
          end
        end.compact

        if instances.empty?
          print "\n  Creating new instance..."
          @instance = conn.launch_instances(AMI, OPTIONS)[0][:aws_instance_id]
          sleep 5
          puts "Done"
        else
          @instance = instances[0]
          @existing = true
        end
        puts "Done (#{@instance})"

        print "Waiting for instance to be available..."
        instance_available
        puts "Done (#{@dns})"
      end

      # Create a builder running the latest code
      task :start => [:find] do
        if @existing
            print "Updating to latest code..."
            `#{SSH} #{@server} 'yum clean all'`
            `#{SSH} #{@server} 'yum update -y'`
            puts "Done"

            # Make sure the right version is installed
            print "Verifying update..."
            rpm = `#{SSH} #{@server} 'rpm -q li'`
            unless rpm.start_with?(@version)
              fail "Expected updated version to be #{@version}, actual was #{rpm}"
            end
            puts "Done"
        else
          print "Performing clean install with the latest code..."
          `#{SSH} #{@server} 'wget http://209.132.178.9/gpxe/trees/li-devenv.sh'`
          `#{SSH} #{@server} 'sh li-devenv.sh'`
          puts "Done"
          print "Updating all packages on the system..."
          `#{SSH} #{@server} 'yum update -y'`
          puts "Done"
          print "Rebooting instance to apply new kernel"
          conn.reboot_instances([@instance])
          sleep 10
          instance_available
          puts "Done"
        end

        # Make sure the name matches the current version
        print "Updating builder tag to latest version..."
        conn.create_tag(@instance, 'Name', "builder-" + @version)
        puts "Done"
      end
    end

    namespace :image do
      desc "Remove the current registered AMI"
      task :clean => ["ami:prereqs"] do
        conn.describe_images_by_owner.each do |i|
          if i[:aws_name] and i[:aws_name].start_with?(@version)
            conn.deregister_image(i[:aws_id])
          end
        end
      end

      # Fails if an AMI for the current version already exists
      task :exists => ["ami:prereqs"] do
        conn.describe_images_by_owner.each do |i|
          if i[:aws_name] and i[:aws_name].start_with?(@version)
            puts "EXITING - AMI already exists"
            exit 0
          end
        end
      end

      desc "Create a new AMI from the latest li build"
      task :new => [:exists, "ami:builder:start"] do
        tag = @existing ? "#{@version}-update" : "#{@version}-clean"
        print "Registering AMI #{@version}..."
        image = conn.create_image(@instance, tag)
        puts "Done"
      end

      # Delete all but the 10 most recent images
      task :prune => ["ami:prereqs"] do
        images = []
        conn.describe_images_by_owner.each do |i|
          if i[:aws_name] and i[:aws_name] =~ AMI_REGEX
            images << i[:aws_id]
          end
        end

        # Keep the 10 most recent images
        images.sort!.pop(10)

        # Prune the rest
        images.each do |i|
          puts "Removing AMI #{i}"
          conn.deregister_image(i)
        end
      end
    end

    namespace :verify do
      desc "Terminate verifier with names matching /#{VERIFIER_REGEX.source}/"
      task :clean => ["ami:prereqs"] do
        # Do not launch if there is a verifier instance running
        instances = conn.describe_instances.collect do |i|
          if (i[:aws_state] == "running") and (i[:tags]["Name"] =~ VERIFIER_REGEX)
            i[:aws_instance_id]
          end
        end.compact
        print "Terminating instances: #{instances.pretty_inspect}"
        conn.terminate_instances([@instance])
      end

      # Make sure that an AMI is available to verify
      task :prereqs => ["ami:prereqs"] do
        # See if the image exists and is available
        images = conn.describe_images_by_owner.collect do |i|
          if i[:aws_name] and i[:aws_name].start_with?(@version)
            @ami = i[:aws_id]
            i[:aws_state]
          end
        end.compact

        if images.empty?
          puts "EXITING - Image doesn't exist for current version"
        elsif images[0] != "available"
          puts "EXITING - Image exists but isn't available yet"
        end
      end

      # A task to allow Jenkins to gracefully exit if the image is verified
      task :already_verified => [:prereqs] do
        # See if the current image is already verified
        conn.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => @ami).each do |tag|
          if tag[:aws_key] == "Name" and tag[:aws_value] == VERIFIED_TAG
            puts "EXITING - Image already verified"
            exit 0
          end
        end
      end

      desc "Update the tests on the current verifier"
      task :update => [:prereqs, :find] do
        print "Updating tests to remote instance..."
        `git archive --prefix li/ HEAD --output /tmp/li.tar`
        `#{SCP} /tmp/li.tar #{@server}:~/`
        `#{SSH} #{@server} 'rm -rf li; tar -xf li.tar'`
        puts "Done"
      end

      task :find => [:prereqs] do
        print "Finding verifier instance..."

        # Look up any tagged instances
        instances = conn.describe_instances.map do |i|
          if (i[:aws_state] == "running") and (i[:tags]["Name"] =~ VERIFIER_REGEX)
            i[:aws_instance_id]
          end
        end.compact

        if instances.empty?
          print "\n  Creating new instance..."
          @instance = conn.launch_instances(@ami, OPTIONS)[0][:aws_instance_id]

          # Quick pause before tagging to reduce errors
          sleep 10
          conn.create_tag(@instance, 'Name', PREFIX + "verifier-#{@version}")
          puts "Done"
        else
          @instance = instances[0]
          @existing = true
        end
        puts "Done (#{@instance})"

        # Wait until the instance is available
        print "Verifying instance is available..."
        instance_available
        puts "Done (#{@dns})"
      end

      desc "Run verification tests on the current version"
      task :start => [:find] do
        print "Updating verifier tag..."
        conn.create_tag(@instance, 'Name', PREFIX + "verifier-#{@version}")
        puts "Done"

        begin
          private_ip = `#{SSH} #{@server} 'facter ipaddress'`.chomp
          print "Updating the controller to use the AMZ private IP '#{private_ip}'..."
          `#{SSH} #{@server} "sed -i \"s/public_ip.*/public_ip='#{private_ip}'/g\" /etc/libra/node_data.conf"`
          `#{SSH} #{@server} "/usr/bin/puppet /usr/libexec/mcollective/update_yaml.pp"`
          `#{SSH} #{@server} "service mcollective restart"`
          puts "Done"

          print "Verifying fact for public_ip is '#{private_ip}'..."
          `#{SSH} #{@server} "mc-facts public_ip | grep found"`.chomp.split[0] == private_ip
          puts "Done"

          print "Installing the mechanize gem..."
          `#{SSH} #{@server} "yum -y install rubygem-nokogiri"`
          `#{SSH} #{@server} "gem install mechanize"`
          puts "Done"

          print "Bounding Apache to pick up the change..."
          `#{SSH} #{@server} 'service httpd restart'`
          `#{SSH} #{@server} 'service libra-site restart'`
          puts "Done"

          print "Creating tests directories..."
          `#{SSH} #{@server} 'mkdir -p /tmp/rhc/junit'`
          puts "Done"

          # Update the test
          Rake::Task["ami:verify:update"].execute

          # Running unit tests
          #print "Running unit tests..."
          #`#{SSH} #{@server} 'cucumber --tags ~@verify --format junit -o /tmp/rhc/junit/ li/tests/'`
          #p1 = $?
          #puts "Done"

          # Run verification tests
          print "Running verification tests..."
          `#{SSH} #{@server} 'cucumber --tags @verify --format junit -o /tmp/rhc/junit/ li/tests/'`
          p2 = $?
          puts "Done"

          print "Downloading verification output..."
          `#{SCP} -r #{@server}:/tmp/rhc .`
          mkdir_p "rhc/log"
          `#{SCP} -r #{@server}:/var/log/httpd/access_log rhc/log`
          `#{SCP} -r #{@server}:/var/log/httpd/error_log rhc/log`
          `#{SCP} -r #{@server}:/var/www/libra/log/development.log rhc/log`
          `#{SCP} -r #{@server}:/var/log/mcollective.log rhc/log`
          `#{SCP} -r #{@server}:/tmp/mcollective-client.log rhc/log`
          puts "Done"

          #if p1.exitstatus != 0
          #  fail "ERROR - Non-zero exit code from unit tests (exit: #{p1.exitstatus})"
          #end

          if p2.exitstatus != 0
            fail "ERROR - Non-zero exit code from verification tests (exit: #{p2.exitstatus})"
          end

          # Only send email / tag if build hasn't be marked as verified yet
          conn.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => @ami).each do |tag|
            if tag[:aws_key] == "Name" and tag[:aws_value] == VERIFIED_TAG
              puts "Not tagging / sending email - already verified"
            else
              print "Tagging image as '#{VERIFIED_TAG}'..."
              conn.create_tag(@ami, 'Name', VERIFIED_TAG) unless ENV['LIBRA_DEV']
              puts "Done"

              print "Sending QE ready email..."
              send_verified_email(@version, @ami)
              puts "Done"
            end
          end
        ensure
          unless ENV['LIBRA_DEV']
            print "Terminating instance..."
            conn.terminate_instances([@instance])
            puts "Done"
          end
        end
      end
    end
  end
rescue LoadError
    # Ignore error - this allows rake to be run from
    # non-development servers
end
