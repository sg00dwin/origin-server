require 'rubygems'
require 'parseconfig'
require 'logger'

module Libra
  def self.configure
    @@config = {}

    # Default to a null logger
    @@config[:logger] = Logger.new('/dev/null')

    # Amazon AWS Configuration
    begin
      # First check for environment variables
      @@config[:aws_key] = ENV['AWS_KEY']
      @@config[:aws_secret] = ENV['AWS_SECRET']
      @@config[:aws_keypair] = ENV['AWS_KEYPAIR']
      @@config[:aws_ami] = ENV['AWS_AMI']
      @@config[:repo_threshold] = ENV['REPO_THRESHOLD'].to_i if ENV['REPO_THRESHOLD']
      @@config[:s3_bucket] = ENV['S3_BUCKET']

      # Optional configuration
      @@config[:aws_name] = ENV['AWS_NAME']
      @@config[:aws_environment] = ENV['AWS_ENVIRONMENT']

      fs_config = ParseConfig.new('/etc/libra/controller.conf')
      @@config[:aws_key] ||= fs_config.get_value('aws_key')
      @@config[:aws_secret] ||= fs_config.get_value('aws_secret')
      @@config[:aws_keypair] ||= fs_config.get_value('aws_keypair')
      @@config[:aws_ami] ||= fs_config.get_value('aws_ami')
      @@config[:repo_threshold] ||= fs_config.get_value('repo_threshold').to_i
      @@config[:s3_bucket] = fs_config.get_value('s3_bucket')

      # Optional configuration
      @@config[:aws_name] = fs_config.get_value('aws_name')
      @@config[:aws_environment] = fs_config.get_value('aws_environment')
    rescue
      # Ignore as long as we have the values below
    ensure
      error_msg = "Not able to find AWS configuration in environment or config file"
      raise Libra::ConfigureException, error_msg unless (@@config[:aws_key] and
                                                         @@config[:aws_secret] and
                                                         @@config[:aws_keypair] and
                                                         @@config[:aws_ami] and
                                                         @@config[:repo_threshold] and
                                                         @@config[:s3_bucket])
    end

    # Now, initialize the MCollective options
    @@config[:rpc_opts] = {:disctimeout => 10,
                           :timeout     => 10,
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
