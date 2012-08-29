require File.expand_path('../../test_helper', __FILE__)

class PromoCodeMailerTest < ActionMailer::TestCase
  test "should send email" do
    Rails.configuration.action_mailer.perform_deliveries = false
    Rails.configuration.action_mailer.raise_delivery_errors = true
    Rails.configuration.action_mailer.delivery_method = :test
    Rails.configuration.email_from = 'OpenShift <noreply@openshift.redhat.com>'
    Rails.configuration.marketing_mailing_list = 'Marketing Mailing List <jgurrero@redhat.com>'
    
    email = PromoCodeMailer.promo_code_email(WebUser.new({:email_address => "test@openshift.com", :promo_code => "promo1"})).deliver
    assert !ActionMailer::Base.deliveries.empty?
    
    assert ['Marketing Mailing List <jgurrero@redhat.com>'], email.to.inspect
    assert 'OpenShift <noreply@openshift.redhat.com>', email.from.inspect
  end
end
