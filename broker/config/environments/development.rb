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
    :integrated => false,
    :broker_auth_secret => "EIvWT6u3lsvSRNRGZhhW8YcWMh5mUAlc32nZlRJPdJM=",
    :broker_auth_rsa_secret => "SJDIkdfhuISe3wrulhjvcKHJFDUeoi8gfcdnu8299dhc",
    :auth_service => {
      :host => "https://streamline-proxy1.ops.rhcloud.com",
      :base_url => "/wapps/streamline"
    }
  }

  config.usage_tracking = {
    :datastore_enabled => true,
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
        },
        :megashift => {
          :max_gears => 16,
          :vip => true,
          :plan_no => 10044931,
          :name => "MegaShift"
        }
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
    :domain_suffix => "dev.rhcloud.com",
    :default_max_gears => 3,

    :dns => {
      :bind => {
        :server => "127.0.0.1",
        :port => 53,
        :keyname => "example.com",
        :keyvalue => "H6NDDnTbNpcBrUM5c4BJtohyK2uuZ5Oi6jxg3ME+RJsNl5Wl2B87oL12YxWUR3Gp7FdZQojTKBSfs5ZjghYxGw==",
        :zone => "example.com"
      }
    }
  }

  # Cloud9
  config.cloud9 = {
    :user_login => "c9",
    :node_profile => "c9"
  }

  # Profiler config
  # See ruby-prof documentation for more info
  # :type     Type of report file: flat (default), graph, graph_html, call_tree, call_stack
  # :measure  Measured property: proc (default), wall, cpu, alloc, mem, gc_runs, gc_time
  # :sqash_threads  Only profile the current thread (def: true)
  # :squash_runtime Don't report common library calls (def: true)
  # :min_percent    Only report calls above this percentage (def: 0)
#  config.profiler = {
#    :type => 'call_tree',
#    :measure => 'wall',
#    :min_percent => 0,
#    :squash_threads => true,
#    :squash_runtime => true
#  }

  config.gearchanger = {
    :rpc_options => {
        :disctimeout => 5,
        :timeout => 180,
        :verbose => false,
        :progress_bar => false,
        :filter => {"identity" => [], "fact" => [], "agent" => [], "cf_class" => []},
        :config => "/etc/mcollective/client.cfg"
    },
    :districts => {
        :enabled => false,
        :require_for_app_create => false,
        :max_capacity => 6000, #Only used by district create
        :first_uid => 1000
    },
    :node_profile_enabled => false
  }

end
