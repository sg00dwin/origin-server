class AccountSupportContactMailer < ActionMailer::Base
  default :to => Rails.application.config.acct_help_mail_to
  
  def contact_email(support_contact)
    @support_contact = support_contact
    Rails.logger.debug "Contact email sent from #{@support_contact.from}"
    mail(:to => Rails.configuration.acct_help_mail_to, :from => @support_contact.from, :subject => @support_contact.subject)
  end
end
