begin
  require 'parseconfig'
  require 'fileutils'
  require 'aws'
  require 'right_http_connection'

  namespace :ami do
    #
    # Global definitions
    #
    AMI = "ami-6a897e03"
    TYPE = "m1.large"
    KEY_PAIR = "libra"
    OPTIONS = {:key_name => KEY_PAIR, :instance_type => TYPE}
    VERSION_REGEX = /li-\d+\.\d+\.\d*-\d+/
    AMI_REGEX = /li-\d+\.\d+/
    BUILD_REGEX = /builder-li-\d+\.\d+/
    VERIFIER_REGEX = /verifier-li-\d+\.\d+/
    BREW_LI = "https://brewweb.devel.redhat.com/packageinfo?packageID=31345"
    GIT_REPO_PUPPET = "ssh://puppet1.ops.rhcloud.com/srv/git/puppet.git"
    CONTENT_TREE = {'puppet' => '/etc/puppet'}
    RSA = File.expand_path("~/.ssh/libra.pem")
    SSH = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -i " + RSA
    SCP = "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -i " + RSA

    # Static initialization
    $stdout.sync = true

    # This will verify the Amazon SSL connection
    Rightscale::HttpConnection.params[:ca_file] = "/etc/pki/tls/certs/ca-bundle.trust.crt"

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
        fail msg
      end

      unless File.exists?(RSA)
        puts "Setting up RSA key"
        libra_key = File.expand_path("../../misc/libra.pem", File.expand_path(__FILE__))
        FileUtils.cp(libra_key, RSA)
        File.chmod(0600, RSA)
      end
    end

    task :yum_clean do
      `yum clean metadata`
      p1 = $?
      `yum info li`
      p2 = $?

      if p1.exitstatus != 0 or p2.exitstatus != 0
        puts "Error cleaning yum state - exiting"
        exit 0
      end
    end

    task :version => [:yum_clean] do
      version = `yum info li | grep Version | tail -n1 | grep -o -E "[0-9]\.[0-9]+\.?[0-9]*"`.chomp

      # Only take the release up until the '.'
      release = `yum info li | grep Release | tail -n1 | grep -o -E "[0-9]\..+"`.chomp
      @version = "li-#{version}-#{release.split('.')[0]}"

      raise "Invalid version format" unless @version =~ VERSION_REGEX

      puts "Current version is #{@version}"
    end

    task :instance => [:version, :creds] do
      puts "Finding instance to use for builder..."
      # Look up any tagged instances
      instances = conn.describe_instances.map do |i|
        if (i[:aws_state] == "running") and (i[:tags]["Name"] =~ BUILD_REGEX)
          i[:aws_instance_id]
        end
      end.compact

      if instances.empty?
        @instance = conn.launch_instances(AMI, OPTIONS)[0][:aws_instance_id]
        sleep 5
        puts "Created new instance #{@instance}"
      else
        @instance = instances[0]
        puts "Using existing instance #{@instance}"
        @update = true
        @existing = true
      end

      # Make sure the name matches the current version
      conn.create_tag(@instance, 'Name', "builder-" + @version)
    end

    task :available => [:instance] do
      # Wait for it to be running
      until instance_value(:aws_state) == "running"
        sleep 5
      end

      @server = "root@" + instance_value(:dns_name)

      # Make sure we can SSH in
      until `#{SSH} #{@server} 'echo Success'`.split[-1] == "Success"
        sleep 5
      end
    end

    task :update => [:available] do
      if @existing
          puts "Updating existing instance"
          `#{SSH} #{@server} 'yum clean all'`
          `#{SSH} #{@server} 'yum update -y'`

          # Make sure the right version is installed
          rpm = `#{SSH} #{@server} 'rpm -q li'`
          unless rpm.start_with?(@version)
            puts "Warning - latest version not available in repo"
            exit 0
          end
      else
        if `#{SSH} #{@server} 'test -e li-devenv.sh; echo $?'`.chomp == "1"
          puts "Running firstboot"
          `#{SSH} #{@server} 'wget http://209.132.178.9/gpxe/trees/li-devenv.sh'`
          `#{SSH} #{@server} 'sh li-devenv.sh'`
          `#{SSH} #{@server} 'yum update -y'`
          conn.reboot_instances([@instance])
          sleep 10
          Rake::Task["ami:available"].execute
        end
      end
    end

    task :check => [:creds, :version] do
      conn.describe_images_by_owner.each do |i|
        if i[:aws_name] and i[:aws_name].start_with?(@version)
          puts "AMI already exists"
          exit 0
        end
      end
    end

    desc "Create a new AMI from the latest li build"
    task :image => [:check, :update, :prune] do
      tag = @update ? "#{@version}-update" : "#{@version}-clean"
      image = conn.create_image(@instance, tag)
      puts "Creating AMI #{image}"
    end

    desc "Remove the current registered AMI and instances"
    task :clean => [:creds, :version] do
      # Terminate any tagged instances
      instances = conn.describe_instances.collect do |i|
        if (i[:aws_state] == "running") and (i[:tags]["Name"] =~ BUILD_REGEX)
          i[:aws_instance_id]
        end
      end.compact

      conn.terminate_instances(instances) unless instances.empty?

      # Deregister any images
      conn.describe_images_by_owner.each do |i|
        if i[:aws_name] and i[:aws_name].start_with?(@version)
          conn.deregister_image(i[:aws_id])
        end
      end
    end

    task :prune => [:creds] do
      images = []
      conn.describe_images_by_owner.each do |i|
        if i[:aws_name] and i[:aws_name] =~ AMI_REGEX
          images << i[:aws_id]
        end
      end

      # Keep the 5 most recent images
      images.sort!.pop(10)

      # Prune the rest
      images.each do |i|
        puts "Removing AMI #{i}"
        conn.deregister_image(i)
      end
    end

    task :current => [:creds, :version] do
      # Find the current AMI
      conn.describe_images_by_owner.each do |i|
        if i[:aws_name] and i[:aws_name].start_with?(@version)
          @ami = i[:aws_id]
          break
        end
      end

      if @ami
        puts "Current AMI for version #{@version} is #{@ami}"
      else
        puts "No AMI exists for current version"
        exit 0
      end
    end

    task :image_available =>[:current] do
      conn.describe_images_by_owner.each do |i|
        if i[:aws_name] and i[:aws_name].start_with?(@version)
          unless i[:aws_state] == "available"
            puts "AMI image for version #{@version} not yet available."
            exit 0
          end
        end
      end
    end

    task :image_prereqs do
      # See if the current image is already verified
      conn.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => @ami).each do |tag|
        if tag[:aws_key] == "Name" and tag[:aws_value] == "dev-verified"
          puts "Image already verified"
          exit 0
        end
      end

      # Do not launch if there is a verifier instance running
      conn.describe_instances.map do |i|
        if (i[:aws_state] == "running") and (i[:tags]["Name"] =~ VERIFIER_REGEX)
          puts "Verifier already running - exiting"
          exit 0
        end
      end
    end

    task :image_verify => [:image_available, :image_prereqs] do
      puts "Launching verification instance for AMI #{@ami}"
      @instance = conn.launch_instances(@ami, OPTIONS)[0][:aws_instance_id]
      conn.create_tag(@instance, 'Name', "verifier-#{@version}")

      # Wait for it to be available
      Rake::Task["ami:available"].execute
      dns = instance_value(:dns_name)
      @server = "root@" + dns

      # Wait a few more seconds to let services start
      sleep 10

      begin
        # Copy the tests to the verifier instance
        puts "Copying tests to remote instance"
        puts "Building an archive of the codebase"
        `git archive HEAD --output /tmp/li.tar`
        puts "Transferring archive"
        `#{SCP} /tmp/li.tar #{@server}:~/`
        puts "Extracting archive"
        `#{SSH} #{@server} 'tar -xf li.tar'`

        private_ip = `#{SSH} #{@server} 'facter ipaddress'`.chomp
        puts "Updating the controller to use the AMZ private IP '#{private_ip}'"
        `#{SSH} #{@server} "sed -i \"s/public_ip.*/public_ip='#{private_ip}'/g\" /etc/libra/node_data.conf"`
        puts "Bounding Apache to pick up the change"
        `#{SSH} #{@server} 'service httpd restart'`

        # Run user tests
        puts "Running regression tests"
        puts `#{SSH} #{@server} 'rake test:all'`
        p = $?

        if p.exitstatus != 0
          puts "ERROR - Non-zero exit code from Cucumber tests (exit: #{p.exitstatus})"
          puts "Cucumber log output:"
          puts `#{SSH} #{@server} 'cat /tmp/rhc/cucumber.log'`
          fail "ERROR - Tests failed"
        end

        # Tag the image as verified
        conn.create_tag(@ami, 'Name', "qe-ready")
      ensure
        puts "Terminating instance"
        conn.terminate_instances([@instance])
      end
    end
  end
rescue LoadError
    # Ignore error - this allows rake to be run from
    # non-development servers
end
