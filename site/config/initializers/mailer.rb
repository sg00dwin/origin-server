Rails.application.config.tap do |config|
  # Mail setup
  config.action_mailer.raise_delivery_errors = Console.config.env(:MAIL_RAISE_ON_DELIVERY_ERRORS, false)
  
  # Read SMTP settings only if available
  Console.config.env(:MAIL_SMTP_SETTINGS){ |c| config.action_mailer.smtp_settings = c }

  # Promo code email
  config.email_from = 'OpenShift Online <noreply@openshift.redhat.com>'
  config.marketing_mailing_list = Console.config.env(:MARKETING_EMAIL_LIST, ['Marketing Mailing List <snathan@redhat.com>'])
end
