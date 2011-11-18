class PromoCodeMailer < ActionMailer::Base
  default :from => "admin@openshift.redhat.com"
  
  def promo_code_email(user)
    @user_email = user.email_address
    @promo_code = user.promo_code
    print @user_email
    mail(:to => Rails.configuration.marketing_mailing_list, :from => Rails.configuration.email_from, :subject => "User signed up with promo code")
  end
end
