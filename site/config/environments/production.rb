RedHatCloud::Application.configure do
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
  config.integrated = true
  config.login = "https://www.redhat.com/wapps/streamline/login.html"
  config.streamline = {
    :host => 'https://www.redhat.com',
    :base_url => '/wapps/streamline',
    :email_confirm_url => '/wapps/streamline/confirm.html',
    :lost_password_url => '/wapps/streamline/resetPassword.html',
    :change_password_url => '/wapps/streamline/protected/changePassword.html',
    :login_url => '/wapps/streamline/login.html',
    :logout_url => '/wapps/sso/logout.html',
    :register_secret => 'c0ldW1n3',
    :user_info_secret => 'sw33tl1Qu0r'
  }
  config.captcha_secret = 'zvw5LiixMB0I4mjk06aR'
  config.sso_verify_interval = 60

  # Aria API information
  config.aria_uri = "https://secure.current.stage.ariasystems.net/api/ws/api_ws_class_dispatcher.php"
  config.aria_auth_key = "sRvjFqjSadu3AFB8jRAR3tqeH5Qf6XjW"
  config.aria_client_no = 3754655


  # Promo code Email notification setup
  config.email_from = 'OpenShift <noreply@openshift.redhat.com>'
  config.marketing_mailing_list = ['Marketing Mailing List <jgurrero@redhat.com>', 'mthompso@redhat.com']
  
  # Express API base url
  config.express_api_url = 'https://localhost'

  # base domain
  config.base_domain = 'rhcloud.com'

  # Max apps for express
  config.express_max_apps = 5

end
