RedHatCloud::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true

  config.cache_store = :memory_store

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  ############################################
  # OpenShift Configuration Below this point #
  ############################################
  config.integrated = false
  config.login = "/app/login"
  config.streamline = {
    :host => 'https://localhost',
    :base_url => '',
    :email_confirm_url => '/confirm.html',
    :lost_password_url => '/lostPassword.html',
    :change_password_url => '/changePassword.html',
    :login_url => '',
    :logout_url => '',
    :register_secret => 'c0ldW1n3',
    :user_info_secret => 'sw33tl1Qu0r',
    :cookie_domain => :nil
  }
  config.captcha_secret = 'secret'
  config.sso_verify_interval = 0

  # Promo code Email notification setup
  config.email_from = 'OpenShift <noreply@openshift.redhat.com>'
  config.marketing_mailing_list = 'Marketing Mailing List <jgurrero@redhat.com>'

  # Maximum number of apps
  config.express_max_apps = 5
  
  # Express API base url
  config.express_api_url = 'https://localhost'

  # base domain
  config.base_domain = 'dev.rhcloud.com'

end
