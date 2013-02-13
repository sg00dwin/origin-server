class AccountSupportContactMailer < ActionMailer::Base
  default :to => Rails.application.config.acct_help_mail_to
  
  def contact_email(user)
    @user_email = user.email_address
    Rails.logger.debug "Contact email sent from #{@user_email}"
    mail(:to => Rails.configuration.acct_help_mail_to, :from => @user_email, :subject => '')
  end
end
