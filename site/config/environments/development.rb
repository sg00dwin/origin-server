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
  config.integrated = false
  config.login = "/app/login"
  config.streamline = {
    :host => 'https://localhost',
    :base_url => '',
    :email_confirm_url => '/confirm.html',
    :lost_password_url => '/wapps/streamline/resetPassword.html',
    :change_password_url => '/wapps/streamline/protected/changePassword.html',
    :login_url => '/wapps/streamline/login.html',
    :logout_url => '/wapps/sso/logout.html',
    :register_secret => '',
    :user_info_secret => '',
    :cookie_domain => :nil,
  }
  config.captcha_secret = 'zvw5LiixMB0I4mjk06aR'
  config.sso_verify_interval = 0
  
  # Promo code Email notification setup
  config.email_from = 'OpenShift <noreply@openshift.redhat.com>'
  config.marketing_mailing_list = 'Marketing Mailing List <jgurrero@redhat.com>'
  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_deliveries = false
  
  # Express API base url
  config.express_api_url = 'https://localhost'

  # base domain
  config.base_domain = 'dev.rhcloud.com'
  
  # Max apps for express
  config.express_max_apps = 5
  
end
