require 'parseconfig'
require 'aws'
require 'lib/openshift/amz/image'
require 'lib/openshift/amz/instance'
require 'lib/openshift/amz/prune'
require 'lib/openshift/amz/verifier'

# Force synchronous stdout
STDOUT.sync, STDERR.sync = true

module OpenShift
  module AWS
    # This will verify the Amazon SSL connection
    Rightscale::HttpConnection.params[:ca_file] = "/etc/pki/tls/certs/ca-bundle.trust.crt"

    @@log = Logger.new(STDOUT)
    @@log.level = Logger::DEBUG

    def log
      @@log
    end

    def setup_rsa_key
      unless File.exists?(RSA)
        log.info "Setting up RSA key..."
        libra_key = File.expand_path("../../../../misc/libra.pem", File.expand_path(__FILE__))
        log.info "Key location = " + libra_key
        FileUtils.cp(libra_key, RSA)
        FileUtils.chmod 0600, RSA
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
        puts e
        raise "Error - no credentials"
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

    def get_amis(conn, filter = DEVENV_REGEX)
      images = {}
      conn.describe_images_by_owner.each do |i|
        if i[:aws_name] and i[:aws_name] =~ filter
          images[i[:aws_name]] = i[:aws_id]
        end
      end
      return images
    end

    def get_latest_ami(conn, filter = DEVENV_REGEX)
      amis = get_amis(conn, filter)

      sorted_keys = amis.keys.sort do |x,y|
        x.split("_")[1].to_i <=> y.split("_")[1].to_i
      end

      return amis[sorted_keys[-1]]
    end
  end
end
