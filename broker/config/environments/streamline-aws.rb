Broker::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  config.log_level = :debug

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  ############################################
  # OpenShift Configuration Below this point #
  ############################################
  config.app_scope = "broker"
  config.integrated = true
  config.streamline = {
    :host => 'https://10.196.215.67',
    :base_url => '/wapps/streamline',
    :register_secret => 'c0ldw1n3',
    :user_info_secret => 'sw33tl1Qu0r'
  }
  
  # CDK Config
  config.cdk = {
    :domain_suffix => "dev.rhcloud.com",
    :zone => "rhcloud.com",
    :child_zone => "dev",
    :per_user_app_limit => 5,
    :broker_auth_secret => "EIvWT6u3lsvSRNRGZhhW8YcWMh5mUAlc32nZlRJPdJM=",
    :broker_auth_rsa_secret => "SJDIkdfhuISe3wrulhjvcKHJFDUeoi8gfcdnu8299dhc",
    :rpc_opts => {
      :disctimeout => 3,
      :timeout     => 30,
      :verbose     => false,
      :progress_bar=> false,
      :filter      => {"identity"=>[], "fact"=>[], "agent"=>[], "cf_class"=>[]},
      :config      => "/etc/mcollective/client.cfg"
    },
    :auth_service => {
      :host => "https://10.196.215.67",
      :base_url => "/wapps/streamline"
    },
    :dynect_customer_name => "demo-redhat",
    :dynect_user_name => "dev-rhcloud-user",
    :dynect_password => "vo8zaijoN7Aecoo",
    :dynect_url => "https://api2.dynect.net",
    
    :aws_key => "AKIAITDQ37BWZ5CKAORA",
    :aws_secret => "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",
    :s3_bucket => "libra_dev",
    
    :nurture_enabled => false,
    :nurture_username => "admin",
    :nurture_password => "password",
    :nurture_url => "http://69.164.192.124:4500/",
    
    :apptegic_enabled => false,
    :apptegic_url => "https://redhat.apptegic.com/httpreceiver",
    :apptegic_key => "redhat",
    :apptegic_secret => "4DC5A0AA-48AE-9287-5F66-9A73E14B6E31",
    :apptegic_dataset => "test"
  }
end
