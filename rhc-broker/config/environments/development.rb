Broker::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and enable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  #config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Disable assets
  #config.assets.enabled = false

  # Disable Rails's static asset server (Apache or nginx will already do this)
  #config.serve_static_assets = false

  # Do not compress assets
  #config.assets.compress = false

  # Set the log level
  config.log_level = :debug

  ############################################
  # OpenShift Configuration Below this point #
  ############################################
  conf = OpenShift::Config.new(File.join(OpenShift::Config::CONF_DIR, 'broker-dev.conf'))

  config.send(:cache_store=, eval("[#{conf.get("CACHE_STORE")}]")) if conf.get("CACHE_STORE")

  config.datastore = {
    :host_port => conf.get("MONGO_HOST_PORT", "localhost:27017"),
    :user => conf.get("MONGO_USER", ""),
    :password => conf.get("MONGO_PASSWORD", ""),
    :db => conf.get("MONGO_DB", "openshift_broker_dev"),
    :ssl => conf.get_bool("MONGO_SSL", "false")
  }

  config.usage_tracking = {
    :datastore_enabled => conf.get_bool("ENABLE_USAGE_TRACKING_DATASTORE", "true"),
    :audit_log_enabled => conf.get_bool("ENABLE_USAGE_TRACKING_AUDIT_LOG", "true"),
    :audit_log_filepath => conf.get("USAGE_TRACKING_AUDIT_LOG_FILE", "/var/log/openshift/broker/usage.log")
  }

  config.analytics = {
    :enabled => conf.get_bool("ENABLE_ANALYTICS", "false"), # global flag for whether any analytics should be enabled
  }

  config.user_action_logging = {
    :logging_enabled => conf.get_bool("ENABLE_USER_ACTION_LOG", "true"),
    :log_filepath => conf.get("USER_ACTION_LOG_FILE", "/var/log/openshift/broker/user_action.log")
  }

  config.maintenance = {
    :enabled => conf.get_bool("ENABLE_MAINTENANCE_MODE", "false"),
    :outage_msg_filepath => conf.get("MAINTENANCE_NOTIFICATION_FILE", "/etc/openshift/outage_notification.txt")
  }

  config.openshift = {
    :domain_suffix => conf.get("CLOUD_DOMAIN", "dev.rhcloud.com"),
    :default_max_gears => (conf.get("DEFAULT_MAX_GEARS", "3")).to_i,
    :default_gear_size => conf.get("DEFAULT_GEAR_SIZE", "small"),
    :gear_sizes => conf.get("VALID_GEAR_SIZES", "small,medium,c9").split(","),
    :default_gear_capabilities => conf.get("DEFAULT_GEAR_CAPABILITIES", "small").split(","),
    :community_quickstarts_url => conf.get('COMMUNITY_QUICKSTARTS_URL'),
    :scopes => ['Scope::Session', 'Scope::Read', 'Scope::Application', 'Scope::Userinfo'],
    :default_scope => 'userinfo',
    :scope_expirations => OpenShift::Controller::Configuration.parse_expiration(conf.get('AUTH_SCOPE_TIMEOUTS'), 1.day),
    :download_cartridges_enabled => conf.get_bool("DOWNLOAD_CARTRIDGES_ENABLED", "true"),
    :ssl_endpoint => conf.get('SSL_ENDPOINT', "allow"),
    :membership_enabled => conf.get_bool("MEMBERSHIP_ENABLED", "false"),
    :max_members_per_resource => conf.get('MAX_MEMBERS_PER_RESOURCE', '100').to_i,
    :max_domains_per_user => conf.get('MAX_DOMAINS_PER_USER', '1').to_i,
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

  config.downloaded_cartridges = {
    :max_downloaded_carts_per_app => conf.get("MAX_DOWNLOADED_CARTS_PER_APP", "5").to_i,
    :max_download_redirects => conf.get("MAX_DOWNLOAD_REDIRECTS", "2").to_i,
    :max_cart_size => conf.get("MAX_CART_SIZE", "20480").to_i,
    :max_download_time => conf.get("MAX_DOWNLOAD_TIME", "10").to_i
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


end
