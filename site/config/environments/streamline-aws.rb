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
  config.app_scope = "app"
  config.integrated = true
  config.login = "https://www.webqa.redhat.com/wapps/streamline/login.html"
  config.streamline_service_base_url = "/wapps/streamline"
  config.streamline = "https://10.196.215.67"
  config.streamline_secret = 'c0ldW1n3'
  config.captcha_secret = 'zvw5LiixMB0I4mjk06aR'
end
