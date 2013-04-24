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
  Rails.logger = Logger.new(STDOUT)

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  config.action_mailer.delivery_method = :test
  config.action_mailer.perform_deliveries = false

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true
  config.assets.logger = false

  Console.configure(ENV['CONSOLE_CONFIG_FILE'] || '/etc/openshift/console.conf')

  config.email_from = 'OpenShift <noreply@openshift.redhat.com>'
  config.marketing_mailing_list = Console.config.env(:MARKETING_EMAIL_LIST, ['Marketing Mailing List <snathan@redhat.com>'])
end
