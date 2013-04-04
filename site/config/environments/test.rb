RedHatCloud::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb
  config.threadsafe!

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
  config.streamline = {
    :host => 'https://streamline-proxy1.ops.rhcloud.com',
    :base_url => '/wapps/streamline',
    :register_secret => 'c0ldW1n3',
    :user_info_secret => 'sw33tl1Qu0r',
    :cookie_domain => nil,
    :timeout => 20
  }
  config.captcha_secret = 'secret'
  config.sso_verify_interval = 0
  config.captcha_types = [:recaptcha]

  # Customer Support Links
  config.customer_support_new_ticket_url = 'https://access.redhat.com/support/cases/new/'

  # Aria API information
  config.aria_enabled = true
  config.aria_uri = "https://streamline-proxy1.ops.rhcloud.com/api/ws/api_ws_class_dispatcher.php"
  config.aria_auth_key = "sRvjFqjSadu3AFB8jRAR3tqeH5Qf6XjW"
  config.aria_client_no = 3754655
  config.aria_default_plan_no = 10330329
  config.aria_force_test_users = true
  config.aria_max_parallel_requests = 5
  # Aria direct post configuration - uses public URL
  # Requires rake aria:set_direct_post be called once per Aria system tested against
  config.aria_direct_post_uri = "https://secure.current.stage.ariasystems.net/api/direct_post.php"
  config.aria_direct_post_name = 'test_website_new_payment'
  config.aria_direct_post_redirect_base = 'https://example.com'

  # Aria invoice template => country mapping
  # The structure of this is:
  #     { '<country_code>' => '<group_name>', ... }
  # The invoice template key is used to assign new aria users to a specific
  # functional account group (Aria concept) that links the customer to a
  # particular invoice template.
  config.aria_invoice_template_map = {
    'AT' => 'EUR_invoice_group',
    'BE' => 'EUR_invoice_group',
    'CA' => 'CA_invoice_group',
    'CH' => 'EUR_invoice_group',
    'DE' => 'EUR_invoice_group',
    'DK' => 'EUR_invoice_group',
    'ES' => 'EUR_invoice_group',
    'FI' => 'EUR_invoice_group',
    'FR' => 'EUR_invoice_group',
    'GB' => 'EUR_invoice_group',
    'IE' => 'EUR_invoice_group',
    'IS' => 'EUR_invoice_group',
    'IT' => 'EUR_invoice_group',
    'LU' => 'EUR_invoice_group',
    'NL' => 'EUR_invoice_group',
    'NO' => 'EUR_invoice_group',
    'PT' => 'EUR_invoice_group',
    'SE' => 'EUR_invoice_group',
    'US' => 'US_invoice_group',
  }

  # Specify allowed countries
  # Add a corresponding value in config/countries.yml if the country uses something other than:
  #  - 'State' for the locality
  #  - 'Postcode' for the postal code
  config.allowed_countries = %w(AT BE CA CH DE DK ES FI FR GB IE IS IT LU NL NO PT SE US).map(&:to_sym)
  # Preferred countries will show up first in the countries list
  config.preferred_countries = [:US]
  # Specify allowed currencies here
  # If a country uses a different currency, it's default will be the first value here
  config.allowed_currencies = [:usd, :eur]
  # Specify accepted cards here. Keys can be found in config/credit_cards.yml
  config.accepted_cards = [:visa, :mastercard, :amex]
  # Disable extended credit card validation rules
  #config.disable_cc_validation = true
  # Disable JS based address form updates
  #config.disable_dynamic_country_form = true

  # Twitter API information
  config.twitter_api_site = 'https://api.twitter.com'
  config.twitter_api_prefix = '/1.1/statuses/'
  config.twitter_oauth_consumer_key = 'kRJ1Hjo3uNd2M8zKCCF0bw'
  config.twitter_oauth_consumer_secret = 'psNvYg3IOAhWtngxBobajkYWKlus53xkNBQxWz3MU'
  config.twitter_oauth_token = '17620820-rm2UBzOWYrETRh2Ut4rjkGISqmkfdlVKSYcmmAOGt'
  config.twitter_oauth_token_secret = 'aFfOPRBJBckWarMxlWYg3MljK6EgoaKUW9CjFSsaG8'

  # Currency
  config.allowed_currencies = [:usd, :cad, :eur] 
  config.default_currency = :usd

  # Promo code Email notification setup
  config.email_from = 'OpenShift <noreply@openshift.redhat.com>'
  config.marketing_mailing_list = 'Marketing Mailing List <jgurrero@redhat.com>'

  # Account Support contact
  config.acct_help_mail_to = 'os.accounts@redhat.com'

  Console.configure do |c|
    c.api = (ENV['CONSOLE_API_MODE'] || 'local').to_sym
    c.community_url = 'https://www.openshift.com/'
  end
end
