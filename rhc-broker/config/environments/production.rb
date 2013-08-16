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

  config.send(:cache_store=, eval("[#{conf.get("CACHE_STORE")}]")) if conf.get("CACHE_STORE")

  config.datastore = {
    :host_port => conf.get("MONGO_HOST_PORT", "localhost:27017"),
    :user => conf.get("MONGO_USER", ""),
    :password => conf.get("MONGO_PASSWORD", ""),
    :db => conf.get("MONGO_DB", "openshift_broker"),
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
    :scopes => ['Scope::Session', 'Scope::Read', 'Scope::Domain', 'Scope::Application', 'Scope::Userinfo'],
    :default_scope => 'userinfo',
    :scope_expirations => OpenShift::Controller::Configuration.parse_expiration(conf.get('AUTH_SCOPE_TIMEOUTS'), 1.day),
    :download_cartridges_enabled => conf.get_bool("DOWNLOAD_CARTRIDGES_ENABLED", "false"),
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
end
