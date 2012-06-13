Broker::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  config.log_level = :debug

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  ############################################
  # OpenShift Configuration Below this point #
  ############################################
  config.districts = {
    :enabled => true,
    :require_for_app_create => false,
    :max_capacity => 6000, # Only used with district create.  Modify capacity through rhc-admin-ctl-district.
    :first_uid => 1000 # Can not modify after district is created.  Only affects new districts.
  }
  
  config.dns = {
    :zone => "rhcloud.com",
    :dynect_customer_name => "demo-redhat",
    :dynect_user_name => "dev-rhcloud-user",
    :dynect_password => "vo8zaijoN7Aecoo",
    :dynect_url => "https://api2.dynect.net"
  }
  
  config.auth = {
    :integrated => true,
    :broker_auth_secret => "EIvWT6u3lsvSRNRGZhhW8YcWMh5mUAlc32nZlRJPdJM=",
    :broker_auth_rsa_secret => "SJDIkdfhuISe3wrulhjvcKHJFDUeoi8gfcdnu8299dhc",
    :auth_service => {
      :host => "https://10.196.215.67",
      :base_url => "/wapps/streamline"
    }
  }
  
  config.usage_tracking = {
    :datastore_enabled => false,
    :syslog_enabled => false
  }
  
  config.rpc_opts = {
    :disctimeout => 2,
    :timeout     => 60,
    :verbose     => false,
    :progress_bar=> false,
    :filter      => {"identity"=>[], "fact"=>[], "agent"=>[], "cf_class"=>[]},
    :config      => "/etc/mcollective/client.cfg"
  }
  
  config.analytics = {
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

  config.datastore = {
    :replica_set => true,
    # Replica set example: [[<host-1>, <port-1>], [<host-2>, <port-2>], ...]
    :host_port => [["localhost", 27017]],
        
    :user => "libra",
    :password => "momo",
    :db => "openshift_broker_dev",
    :collections => {:user => "user", 
                     :district => "district", 
                     :application_template => "template",
                     :distributed_lock => "distributed_lock"}
  }

  config.user_action_logging = {
    :logging_enabled => true,
    :log_filepath => "/var/log/stickshift/user_action.log"
  }
  
  # SS Config
  config.ss = {
    :domain_suffix => "dev.rhcloud.com",
    :default_max_gears => 3
  }

  # Cloud9
  config.cloud9 = {
    :user_login => "c9",
    :node_profile => "c9"
  }

end
