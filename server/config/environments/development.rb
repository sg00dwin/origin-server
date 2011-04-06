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

  # Determines whether HTTPS constraints should be enforced for this
  # environment - i.e. whether to enforce HTTPS for login, etc.
  config.secure_protocol = "http"
  config.app_scope = "app"

  # Integration environment constraints - uncommenting these will
  #   registrations, logins, and authorizations to hit the IT service
  config.streamline = "https://streamline.devlab.phx1.redhat.com/wapps/streamline"
  config.streamline_secret = 'c0ldW1n3'

  # AWS configuration
  config.aws_key = "AKIAJMZR4X6F46UMXV6Q"
  config.aws_secret = "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"
  config.aws_keypair = "libra"
  config.aws_name = "libra-node"
  config.aws_environment = "demo"
  config.aws_ami = "N/A"
  config.repo_threshold = 100
  config.s3_bucket = "libra-dev"

  # DDNS configuration
  config.libra_domain = "rhcloud.com"
  config.resolver = "209.132.178.9"
  config.secret = "hmac-md5:dhcpupdate:fzAvGcKPZWiFgmF8qmNUaA=="

  # Broker configuration
  config.per_user_app_limit = 1
end

