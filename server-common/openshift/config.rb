require 'rubygems'
require 'parseconfig'
require 'logger'

module OpenShift
  def self.configure
    @@config = {}

    # Default to a null logger
    @@config[:logger] = Logger.new('/dev/null')

    # Amazon AWS Configuration
    begin

      fs_config = ParseConfig.new('/etc/libra/controller.conf')
      @@config[:aws_key] ||= fs_config.get_value('aws_key')
      @@config[:aws_secret] ||= fs_config.get_value('aws_secret')
      @@config[:aws_keypair] ||= fs_config.get_value('aws_keypair')
      @@config[:aws_ami] ||= fs_config.get_value('aws_ami')
      @@config[:repo_threshold] ||= fs_config.get_value('repo_threshold').to_i
      @@config[:s3_bucket] = fs_config.get_value('s3_bucket')

      # DDNS configuration
      @@config[:libra_zone] = fs_config.get_value('libra_zone')
      child_zone = fs_config.get_value('libra_child_zone')
      @@config[:libra_child_zone] = child_zone
      @@config[:libra_domain] = (child_zone.empty? ? '' : child_zone + '.') + @@config[:libra_zone]

      # Optional configuration
      @@config[:aws_name] = fs_config.get_value('aws_name')
      @@config[:aws_environment] = fs_config.get_value('aws_environment')
      per_user_app_limit = fs_config.get_value('per_user_app_limit')
      @@config[:per_user_app_limit] =  per_user_app_limit ? per_user_app_limit.to_i : 100
    rescue
      # Ignore as long as we have the values below
    ensure
      error_msg = "Not able to find AWS configuration in environment or config file"
      raise OpenShift::OpenShiftException.new(199), error_msg, caller[0..5] unless (@@config[:aws_key] and
                                                         @@config[:aws_secret] and
                                                         @@config[:aws_keypair] and
                                                         @@config[:aws_ami] and
                                                         @@config[:repo_threshold] and
                                                         @@config[:s3_bucket])
    end

    # Now, initialize the MCollective options
    @@config[:rpc_opts] = {:disctimeout => 3,
                           :timeout     => 30,
                           :verbose     => false,
                           :progress_bar=> false,
                           :filter      => {"identity"=>[], "fact"=>[], "agent"=>[], "cf_class"=>[]},
                           :config      => "/etc/mcollective/client.cfg"}
  end

  # Configuration access shortcut
  def self.c
    @@config
  end

  # Run the configuration method
  configure
end
