RedHatCloud::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  config.log_level = :debug

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
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
  config.integrated = true
  config.login = "https://www.qa.redhat.com/wapps/streamline/login.html"
  config.streamline = {
    :host => 'https://10.196.215.67',
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
  config.aria_default_plan_no = 10044929

  # Promo code Email notification setup
  config.email_from = 'OpenShift <noreply@openshift.redhat.com>'
  config.marketing_mailing_list = 'Marketing Mailing List <jgurrero@redhat.com>'

  # Express API base url
  config.express_api_url = 'https://localhost'

  # base domain
  config.base_domain = 'dev.rhcloud.com'

  config.express_max_apps = 5

end
