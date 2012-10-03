Broker::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and enable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  ############################################
  # OpenShift Configuration Below this point #
  ############################################
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
    :collections => {:user => "user_test",
                     :district => "district_test", 
                     :application_template => "template_test",
                     :distributed_lock => "distributed_lock_test"}
  }

  config.user_action_logging = {
    :logging_enabled => true,
    :log_filepath => "/var/log/stickshift/user_action.log"
  }

  config.billing = {
    :aria => {
      :config => {
        :url => "https://streamline-proxy1.ops.rhcloud.com/api/ws/api_ws_class_dispatcher.php",
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
      :default_plan => :freeshift,
      :plans => {
        :freeshift => {
          :plan_no => 10044929,
          :name => "FreeShift",
          :capabilities => {
            'max_gears' => 3,
            'gear_sizes' => ["small"]
          }
        },
        :megashift => {
          :plan_no => 10044931,
          :name => "MegaShift",
          :capabilities => {
            'max_gears' => 16,
            'gear_sizes' => ["small", "medium"],
            'max_storage_per_gear' => 30 # 30GB
          }
        }
      },
      :supp_plans => {}
    }
  }

  # SS Config
  config.ss = {
    :domain_suffix => "dev.rhcloud.com",
    :default_max_gears => 3,
    :default_gear_size => "small"
  }

  # Profiler config
#  config.profiler = {
#    :type => 'call_tree',
#    :measure => 'wall',
#    :min_percent => 0,
#    :squash_threads => true,
#    :squash_runtime => true
#  }

  # mcollective configuration
  config.gearchanger = {
    :rpc_options => {
        :disctimeout => 2,
        :timeout => 180,
        :verbose => false,
        :progress_bar => false,
        :filter => {"identity" => [], "fact" => [], "agent" => [], "cf_class" => []},
        :config => "/etc/mcollective/client.cfg"
    },
    :districts => {
        :enabled => true,
        :require_for_app_create => false,
        :max_capacity => 6000, # Only used with district create.  Modify capacity through ss-admin-ctl-district.
        :first_uid => 1000 # Can not modify after district is created.  Only affects new districts.
    },
    :node_profile_enabled => false
  }


end
