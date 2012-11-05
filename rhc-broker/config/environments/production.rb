Broker::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable assets
  config.assets.enabled = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  # Set the log level
  config.log_level = :debug


  ############################################
  # OpenShift Configuration Below this point #
  ############################################
  conf = OpenShift::Config.new(File.join(OpenShift::Config::CONF_DIR, 'broker.conf'))
  replica_sets = conf.get_bool("MONGO_REPLICA_SETS", "false")
  hp = conf.get("MONGO_HOST_PORT", "localhost:27017")
  if !hp
    raise "Broker is missing Mongo configuration."
  elif replica_sets
    host_port = hp.split.map do |x|
      (h,p) = x.split(":")
      [h, p.to_i]
    end
  else
    (h,p) = hp.split(":")
    host_port = [h, p.to_i]
  end
  
  config.datastore = {
    :replica_set => replica_sets,
    :host_port => host_port,
  
    :user => conf.get("MONGO_USER", ""),
    :password => conf.get("MONGO_PASSWORD", ""),
    :db => conf.get("MONGO_DB", "openshift_broker_dev"),
    :collections => {:user => "user",
                     :district => "district",
                     :application_template => "template",
                     :distributed_lock => "distributed_lock"}
  }

  config.usage_tracking = {
    :datastore_enabled => conf.get_bool("ENABLE_USAGE_TRACKING_DATASTORE", "true"),
    :syslog_enabled => conf.get_bool("ENABLE_USAGE_TRACKING_SYSLOG", "false")
  }
  
  config.analytics = {
    :enabled => conf.get_bool("ENABLE_ANALYTICS", "false"), # global flag for whether any analytics should be enabled
  }
  
  config.user_action_logging = {
    :logging_enabled => conf.get_bool("ENABLE_USER_ACTION_LOG", "true"),
    :log_filepath => conf.get("USER_ACTION_LOG_FILE", "/var/log/openshift/user_action.log")
  }
  
  config.openshift = {
    :domain_suffix => conf.get("CLOUD_DOMAIN", "dev.rhcloud.com"),
    :default_max_gears => (conf.get("DEFAULT_MAX_GEARS", "3")).to_i,
    :default_gear_size => conf.get("DEFAULT_GEAR_SIZE", "small"),
    :gear_sizes => conf.get("VALID_GEAR_SIZES", "small,medium,c9").split(",")
  }
  
  config.auth = {
    # formerly the broker_auth_secret
    :salt => conf.get("AUTH_SALT", ""),
    :privkeypass => conf.get("AUTH_PRIV_KEY_PASS", ""),
    :privkeyfile => conf.get("AUTH_PRIV_KEY_FILE", ""),
    :pubkeyfile  => conf.get("AUTH_PUB_KEY_FILE", ""),
    :rsync_keyfile => conf.get("AUTH_RSYNC_KEY_FILE", ""),
  }

  config.analytics = {
    :enabled => conf.get_bool("ENABLE_ANALYTICS", "false"),
    :nurture => {
      :enabled => conf.get_bool("ENABLE_NURTURE", "false"),
      :username => conf.get("NURTURE_USERNAME", ""),
      :password => conf.get("NURTURE_PASSWORD", ""),
      :url => conf.get("NURTURE_URL", ""),
    }
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
end
