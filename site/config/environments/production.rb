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

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  config.assets.compile = false
  config.assets.initialize_on_precompile = false

  if $rails_rake_task
    # Settings specific to the production environment build task

    # Workaround for Rails 3.2.x and threadsafe!
    config.dependency_loading = true
    
    config.assets.compress = true
    # Digest is disabled so we serve the same resources
    #config.assets.digest = true
    config.assets.js_compressor = :uglifier
    config.assets.precompile += %w(application.js
                                   console.js
                                   modernizr.min.js
                                   jquery.payment.js
                                   site/home.js
                                   site/tracking.js
                                   site/omniture.js
                                   site/s_code.js
                                   site/picatcha.js
                                   site/address.js
                                   common.css
                                   console.css
                                   site.css
                                   overpass.css
                                   picatcha.css
                                   plan_upgrade.css
                                  )
  else
    # Settings specific to the production environment server launch
  end

  Console.configure(ENV['CONSOLE_CONFIG_FILE'] || '/etc/openshift/console.conf')

  # Promo code Email notification setup
  config.email_from = 'OpenShift <noreply@openshift.redhat.com>'
  config.marketing_mailing_list = Console.config.env(:MARKETING_EMAIL_LIST, ['Marketing Mailing List <snathan@redhat.com>'])
end
