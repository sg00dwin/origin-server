Broker::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  ############################################
  # OpenShift Configuration Below this point #
  ############################################
  config.districts = {
    :enabled => true,
    :require_for_app_create => true,
    :max_capacity => 6000, # Only used with district create.  Modify capacity through rhc-admin-ctl-district.
    :first_uid => 1000 # Can not modify after district is created.  Only affects new districts.
  }
  
  config.dns = {
    :zone => "rhcloud.com",
    :dynect_customer_name => "demo-redhat",
    :dynect_user_name => "390XFV-dev-user",
    :dynect_password => "Mei5aeru6yahchee",
    :dynect_url => "https://api2.dynect.net"
  }
  
  config.auth = {
    :integrated => true,
    :broker_auth_secret => "EIvWT6u3lsvSRNRGZhhW8YcWMh5mUAlc32nZlRJPdJM=",
    :broker_auth_rsa_secret => "SJDIkdfhuISe3wrulhjvcKHJFDUeoi8gfcdnu8299dhc",
    :auth_service => {
      :host => "https://www.redhat.com",
      :base_url => "/wapps/streamline"
    }
  }
  
  config.usage_tracking = {
    :datastore_enabled => false,
    :syslog_enabled => false
  }
  
  config.rpc_opts = {
    :disctimeout => 2,
    :timeout     => 180,
    :verbose     => false,
    :progress_bar=> false,
    :filter      => {"identity"=>[], "fact"=>[], "agent"=>[], "cf_class"=>[]},
    :config      => "/etc/mcollective/client.cfg"
  }
  
  config.analytics = {
    :nurture_enabled => true,
    :nurture_username => "admin",
    :nurture_password => "password",
    :nurture_url => "https://libra-makara.nurturehq.com/",
    
    :apptegic_enabled => false,
    :apptegic_url => "https://redhat.apptegic.com/httpreceiver",
    :apptegic_key => "redhat",
    :apptegic_secret => "4DC5A0AA-48AE-9287-5F66-9A73E14B6E31",
    :apptegic_dataset => "test"
  }

  config.datastore = {
    :replica_set => true,
    # Replica set example: [[<host-1>, <port-1>], [<host-2>, <port-2>], ...]
    :host_port => [["HOST_NAME", 27017]],
        
    :user => "USER_NAME",
    :password => "PASSWORD",
    :db => "openshift_broker",
    :collections => {:user => "user", 
                     :district => "district", 
                     :application_template => "template",
                     :distributed_lock => "distributed_lock"}
  }

  config.user_action_logging = {
    :logging_enabled => true,
    :log_filepath => "/var/log/stickshift/user_action.log"
  }

  config.billing = {
    :aria => {
      :config => {
        :url => "https://secure.current.stage.ariasystems.net/api/ws/api_ws_class_dispatcher.php",
        :auth_key => "sRvjFqjSadu3AFB8jRAR3tqeH5Qf6XjW",
        :client_no => 3754655
      },
      :usage_type => {
        :gear => {:small => 10014123,
                  :medium => 10014125,
                  :large => 10014127,
                  :xlarge => 10014151},
        :storage => {:gigabyte_hour => 10037755}
      },
      :datastore_enabled => false,
      :default_max_gears => 3,
      :plans => {
        :freeshift => {
          :max_gears => 3,
          :vip => false,
          :plan_no => 10044929,
          :name => "FreeShift"
        }
#        :megashift => {
#          :max_gears => 16,
#          :vip => true,
#          :plan_no => 10044931,
#          :name => "MegaShift"
#        }
      },
      :supp_plans => {
        :megashiftstorage => {
          :parent_plan => :megashift,
          :plan_no => 10088295,
          :name => "MegaShiftStorage"
          #TBD
        }
      }
    }
  }

  # SS Config
  config.ss = {
    :domain_suffix => "rhcloud.com",
    :default_max_gears => 3
  }

  # Cloud9
  config.cloud9 = {
    :user_login => "c9",
    :node_profile => "c9"
  }

  config.gearchanger = {
    :rpc_options => {
        :disctimeout => 5,
        :timeout => 60,
        :verbose => false,
        :progress_bar => false,
        :filter => {"identity" => [], "fact" => [], "agent" => [], "cf_class" => []},
        :config => "/etc/mcollective/client.cfg"
    },
    :districts => {
        :enabled => true,
        :require_for_app_create => true,
        :max_capacity => 6000, #Only used by district create
        :first_uid => 1000
    },
    :node_profile_enabled => true
  }

end
