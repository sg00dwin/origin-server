RedHatCloud::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false
  config.reload_plugins = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  config.log_level = :debug

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
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
  config.integrated = false
  config.streamline = {
    :host => 'https://streamline-proxy1.ops.rhcloud.com',
    :base_url => '/wapps/streamline',
    :register_secret => 'c0ldW1n3',
    :user_info_secret => 'sw33tl1Qu0r',
    :cookie_domain => :nil,
    :timeout => 5
  }
  config.captcha_secret = 'zvw5LiixMB0I4mjk06aR'
  config.sso_verify_interval = 0

  # Aria API information
  config.aria_enabled = true
  config.aria_uri = "https://streamline-proxy1.ops.rhcloud.com/api/ws/api_ws_class_dispatcher.php"
  config.aria_auth_key = "sRvjFqjSadu3AFB8jRAR3tqeH5Qf6XjW"
  config.aria_client_no = 3754655
  config.aria_default_plan_no = 10044929
  config.aria_force_test_users = true
  # Aria direct post configuration - uses public URL
  config.aria_direct_post_uri = "https://secure.current.stage.ariasystems.net/api/direct_post.php"
  config.aria_direct_post_name = nil
  config.aria_direct_post_redirect_base = nil

  # Promo code Email notification setup
  config.email_from = 'OpenShift <noreply@openshift.redhat.com>'
  config.marketing_mailing_list = 'Marketing Mailing List <jgurrero@redhat.com>'
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_deliveries = false

  Console.configure do |c|
    c.api = (ENV['CONSOLE_API_MODE'] || 'local').to_sym
    #c.disable_account = true
  end
end
