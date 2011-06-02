require 'parseconfig'
require 'aws'

# Force synchronous stdout
STDOUT.sync, STDERR.sync = true

# This will verify the Amazon SSL connection
Rightscale::HttpConnection.params[:ca_file] = "/etc/pki/tls/certs/ca-bundle.trust.crt"

module OpenShift
  module AWS
    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG

    def setup_rsa_key
      unless File.exists?(RSA)
        print "Setting up RSA key..."
        libra_key = File.expand_path("../../misc/libra.pem", File.expand_path(__FILE__))
        FileUtils.cp(libra_key, RSA)
        FileUtils.chmod 0600, RSA
        puts "Done"
      end
    end

    def connect
      begin
        # Parse the credentials
        config = ParseConfig.new(File.expand_path("~/.awscred"))

        # Setup the SSH key
        setup_rsa_key

        # Return the AMZ connection
        Aws::Ec2.new(config.get_value("AWSAccessKeyId"), 
                     config.get_value("AWSSecretKey"), 
                     params = {:logger => Logger.new('/dev/null')})
      rescue StandardError => e
        puts <<-eos
          Couldn't access credentials in ~/.awscred

          Please create a file with the following format:
            AWSAccessKeyId=<ACCESS_KEY>
            AWSSecretKey=<SECRET_KEY>
        eos
        raise "Error - no credentials"
      end
    end

    class Instance
      attr_accessor :conn, :amz_id, :name, :dns

      def log
        @@log
      end

      def initialize(conn, name)
        @conn, @name = conn, name

        log.info "Creating new instance..."

        # Launch a new instance
        @amz_id = @conn.launch_instances(AMI, OPTIONS)[0][:aws_instance_id]

        # Small sleep to avoid exceptions in AMZ call
        sleep 2

        # Tag the instance
        @conn.create_tag(@amz_id, 'Name', @name)

        # Block until the instance is accessible
        block_until_available
      end

      def terminate
        log.info "Terminating instance (#{@amz_id})..."
        @conn.terminate_instances([@amz_id])
      end

      def reboot
        log.info "Rebooting instance (#{@amz_id})..."
        @conn.reboot_instances([@amz_id])

        # Allow time for the instance to actually shutdown
        sleep 10

        # Block until the instance is SSH available
        block_until_available
      end

      def ssh(cmd, timeout=60)
        log.debug "(ssh: server = #{@dns} / timeout = #{timeout} / cmd = #{cmd})"
        output = ""
        begin
          ssh_cmd = "#{SSH} root@#{@dns} '#{cmd}'"
          Timeout::timeout(timeout) { output = `#{ssh_cmd}`.chomp }
        rescue Timeout::Error
          log.error "SSH command timed out"
        end
        log.debug "----------------------------\n#{output}\n----------------------------"
        return output
      end

      def scp(from, to, timeout=60)
        log.debug "(scp: timeout = #{timeout}) / from = '#{from}' to = '#{to}'"
        output = ""
        begin
          scp_cmd = "#{SCP} -r #{from} root@#{@dns}:#{to}"
          Timeout::timeout(timeout) { output = `#{scp_cmd}`.chomp }
        rescue Timeout::Error
          log.error "SCP command '#{scp_cmd}' timed out"
        end
        log.debug "----------------------------\n#{output}\n------------------------------"
        return output
      end

      def retry_block(retry_msg, max_retries = 15)
        (0..max_retries).each do
          break if yield
          log.info retry_msg + "... retrying"
          sleep 5
        end
       
        unless yield
          raise "Operation Timed Out"
        end
      end

      def block_until_available
        log.info "Waiting for instance to be available..."

        (0..15).each do
          break if is_running?
          log.info "Instance isn't running yet... retrying"
          sleep 5
        end

        unless is_running?
          terminate
          raise "Timed out before instance was 'running'"
        end

        # Establish the DNS name
        @dns = get_value(:dns_name)

        (0..15).each do
          break if can_ssh?
          log.info "SSH access failed... retrying"
          sleep 5
        end

        unless can_ssh?
          terminate 
          raise "SSH availability timed out"
        end

        log.info "Instance (#{@amz_id} / #{@dns}) is accessible"
      end

      def get_value(key)
        @conn.describe_instances([@amz_id])[0][key]
      end

      def is_running?
        get_value(:aws_state) == "running"
      end

      def can_ssh?
        ssh('echo Success', 10).split[-1] == "Success"
      end

      def is_valid?
        output = ssh('/usr/bin/rhc-accept-node')
        log.info "Node Acceptance Output = #{output}"
        output == "PASS"
      end
    end

    class Image
      attr_accessor :conn, :amz_id, :name

      def log
        @@log
      end

      def initialize(conn, instance_id, name, desc = "")
        log.info "Registering AMI based on instance (#{instance})..."

        @conn, @name, @desc = conn, name, desc
        @amz_id = @conn.create_image(instance_id, name, desc)

        (0..30).each do
          break if get_value(:aws_state) == 'available'
          log.info "Image not available yet..."
          sleep 60
        end

        unless get_value(:aws_state) == 'available'
          raise "Operation Timed Out"
        end

        log.info "Done"
      end

      def get_value(key)
        @conn.describe_images([@amz_id], 'machine')[0][key]
      end
    end
end

def send_verified_email(version, ami)
    msg = <<END_OF_MESSAGE
From: Jenkins <noreply@redhat.com>
To: Matt Hicks <mhicks@redhat.com>
Subject: Jenkins Build #{version} QE Ready

The build #{version} (AMI #{ami}) is ready for QE.
END_OF_MESSAGE

    Net::SMTP.start('localhost') do |smtp|
      smtp.send_message msg, "noreply@redhat.com", "libra-express@redhat.com"
    end
  end
end

def get_version(package)
  yum_output = `yum info #{package}`

  # Process the yum output to get a version
  version = yum_output.split("\n").collect do |line|
    line.split(":")[1].strip if line.start_with?("Version")
  end.compact[-1]

  # Process the yum output to get a release
  release = yum_output.split("\n").collect do |line|
    line.split(":")[1].strip if line.start_with?("Release")
  end.compact[-1]

  return "#{version}-#{release.split('.')[0]}"
end

def check_update
  yum_output = `yum check-update rhc-*`

  # For testing
  yum_output = <<-eos
Loaded plugins: product-id, security, subscription-manager
Updating Red Hat repositories.
Skipping security plugin, no data

rhc.noarch                  0.72.2-1.el6            li                          
rhc-common.noarch           0.72.1-2.el6            li                          
rhc-devenv.noarch           0.72.2-1.el6            li                          
rhc-node.noarch             0.72.3-1.el6            li                          
Obsoleting Packages
ipa-client.x86_64           2.0.0-23.el6            rhel-server-6-updates       
    ipa-client.x86_64       2.0-9.el6               @koji-override-0/$releasever
qpid-qmf.x86_64             0.10-6.el6              rhel-server-6-updates       
    qmf.x86_64              0.7.946106-13.el6       @qpid                       
ruby-qpid-qmf.x86_64        0.10-6.el6              rhel-server-6-updates       
    ruby-qmf.x86_64         0.7.946106-13.el6       @qpid     
eos

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
