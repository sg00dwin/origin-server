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
    BUILD_REGEX = /li-\d\.\d{2}/
    BREW_LI = "https://brewweb.devel.redhat.com/packageinfo?packageID=31345"
    GIT_REPO_PUPPET = "ssh://puppet1.ops.rhcloud.com/srv/git/puppet.git"
    CONTENT_TREE = {'puppet' => '/etc/puppet'}
    RSA = File.expand_path("~/.ssh/libra-new.pem")
    SSH = "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PasswordAuthentication=no -i " + RSA

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

    def get_instance
      # Look up any tagged instances
      instances = conn.describe_images_by_owner.map {|i| i[:aws_id] if i[:aws_name] == @version}.compact

      if instances.empty?
        puts "Creating new instance..."
        options = {:key_name => KEY_PAIR, :instance_type => TYPE}
        @instance = conn.launch_instances(AMI, options)[0][:aws_instance_id]
        puts "Created new instance #{@instance}"
      else
        @instance = instances[0]
        puts "Found running instance #{@instance}"
      end
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
        libra_key = File.expand_path("../../docs/libra-new.pem", File.expand_path(__FILE__))
        FileUtils.cp(libra_key, RSA)
        File.chmod(0600, RSA)
      end
    end

    task :version do
      version = `yum info li | grep Version | tail -n1 | grep -o -E "[0-9]\.[0-9]+"`.chomp

      # Only take the release up until the '.'
      release = `yum info li | grep Release | tail -n1 | grep -o -E "[0-9]\..+"`.chomp
      @version = "li-#{version}-#{release.split('.')[0]}"
      puts "Current version is #{@version}"
    end

    task :instance => [:version, :creds] do
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
      conn.create_tag(@instance, 'Name', @version)
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
          `#{SSH} #{@server} 'yum update -y'`
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
        if i[:aws_name] and i[:aws_name] =~ BUILD_REGEX
          images << i[:aws_name]
        end
      end

      # Keep the 5 most recent images
      images.sort!.pop(5)

      # Prune the rest
      images.each do |name|
        puts "Removing AMI #{name}"
        conn.deregister_image(name)
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

    task :image_verify => [:image_available] do
      # See if the current image is already verified
      conn.describe_tags('Filter.1.Name' => 'resource-id', 'Filter.1.Value.1' => @ami).each do |tag|
        if tag[:aws_key] == "Name" and tag[:aws_value] == "dev-verified"
          puts "Image already verified"
          exit 0
        end
      end

      puts "Launching verification instance for AMI #{@ami}"
      @instance = conn.launch_instances(@ami, OPTIONS)[0][:aws_instance_id]
      conn.create_tag(@instance, 'Name', "#{@version}-verify")

      # Wait for it to be available
      Rake::Task["ami:available"].execute
      dns = instance_value(:dns_name)

      # Wait a few more seconds to let services start
      sleep 10

      begin
        # Test user creation and app creation
        puts "Testing user creation"
        chars = ("1".."9").to_a
        namespace = "jenkins" + Array.new(5, '').collect{chars[rand(chars.size)]}.join

        puts "Setting up the config file"
        File.open("client.conf", "w") do |file|
          file.puts "libra_domain='rhcloud.com'"
          file.puts "li_server='#{dns}'"
        end

        puts "Creating a new user..."
        sh "rhc-create-domain -n #{namespace} -l libra-test+#{namespace}@redhat.com -p test"
        puts "Creating a new app..."
        sh "rhc-create-app -a mytest -t php-5.3.2 -l libra-test+#{namespace}@redhat.com -n -p blah"

        # Tag the image as verified
        conn.create_tag(@ami, 'Name', "dev-verified")
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
