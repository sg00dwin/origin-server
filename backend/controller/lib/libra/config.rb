require 'rubygems'
require 'parseconfig'

module Libra
  def self.configure
    puts "Beginning Libra Configuration"

    @@config = {}

    # Default to a null logger
    @@config[:logger] = Logger.new('/dev/null')

    # Amazon AWS Configuration
    begin
      # First check for environment variables
      @@config[:aws_key] = ENV['S3_AWS_KEY']
      @@config[:aws_secret] = ENV['S3_AWS_SECRET']

      unless @@config[:aws_key] or @@config[:aws_secret]
        # Then, try and parse the config file
        fs_config = ParseConfig.new('/etc/libra/libra_s3.conf')
        @@config[:aws_key] ||= fs_config.aws_key
        @@config[:aws_secret] ||= fs_config.aws_secret
      end
    ensure
      error_msg = "Not able to find AWS configuration in environment or config file"
      raise ConfigureException error_msg unless (@@config[:aws_secret] and @@config[:aws_secret])
    end

    # Now, initialize the MCollective options
    @@config[:rpc_opts] = {:disctimeout => 2,
                           :timeout     => 5,
                           :verbose     => false,
                           :filter      => {"identity"=>[], "fact"=>[], "agent"=>[], "cf_class"=>[]},
                           :config      => "/etc/mcollective/client.cfg"}
  end

  # Configuration access shortcut
  def c
    @@config
  end

  # Run the configuration method
  configure
end
