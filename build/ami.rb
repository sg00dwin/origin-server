require 'fileutils'
require 'parseconfig'
begin
  require 'aws'
  require 'right_http_connection'

  namespace :ami do
    #
    # Global definitions
    #
    BREW_LI = "https://brewweb.devel.redhat.com/packageinfo?packageID=31345"
    GIT_REPO_PUPPET="ssh://puppet1.ops.rhcloud.com/srv/git/puppet.git"
    CONTENT_TREE={'puppet' => '/etc/puppet'}
    RSA = File.expand_path("../../docs/libra-new.pem", File.expand_path(__FILE__))
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
        options = {:key_name => "libra", :instance_type => "m1.large"}
        @instance = conn.launch_instances("ami-6a897e03", options)[0][:aws_instance_id]
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
    end

    task :version do
      @version = `curl -s #{BREW_LI} | grep -o -E li-.{4} | head -n1`.chomp
      puts "Current version is #{@version}"
    end

    task :instance => [:version, :creds] do
      # Look up any tagged instances
      instances = conn.describe_instances.map do |i|
        if (i[:aws_state] == "running") and (i[:tags]["Name"] == @version)
          i[:aws_instance_id]
        end
      end.compact

      if instances.empty?
        options = {:key_name => "libra", :instance_type => "m1.large"}
        @instance = conn.launch_instances("ami-6a897e03", options)[0][:aws_instance_id]
        sleep 5
        conn.create_tag(@instance, 'Name', @version)
        puts "Created new instance #{@instance}"
      else
        @instance = instances[0]
        puts "Using existing instance #{@instance}"
      end
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

    task :firstboot => [:available] do
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

    task :check => [:creds, :version] do
      conn.describe_images_by_owner.each do |i|
        fail "AMI already exists" if i[:aws_name] == @version
      end
    end

    desc "Create a new AMI from the latest li build"
    task :image => [:check, :firstboot] do
      image = conn.create_image(@instance, @version)
      puts "Creating AMI #{image}"
    end

    desc "Remove the current registered AMI and instances"
    task :clean => [:creds, :version] do
      # Terminate any tagged instances
      instances = conn.describe_instances.collect do |i|
        if (i[:aws_state] == "running") and (i[:tags]["Name"] == @version)
          i[:aws_instance_id]
        end
      end.compact

      conn.terminate_instances(instances) unless instances.empty?

      # Deregister any images
      conn.describe_images_by_owner.each do |i|
        if i[:aws_name] == @version
          conn.deregister_image(i[:aws_id])
        end
      end
    end
  end
rescue LoadError
    # Ignore error - this allows rake to be run from
    # non-development servers
end
