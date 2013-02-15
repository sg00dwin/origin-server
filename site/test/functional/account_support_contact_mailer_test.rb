require File.expand_path('../../test_helper', __FILE__)

class AccountSupportContactMailerTest < ActionMailer::TestCase
  test "should send email" do
    recipient = Rails.configuration.acct_help_mail_to
    test_mail_from = 'test@example.com'
    Rails.configuration.action_mailer.perform_deliveries = false
    Rails.configuration.action_mailer.raise_delivery_errors = true
    Rails.configuration.action_mailer.delivery_method = :test
    Rails.configuration.email_from = test_mail_from
    Rails.configuration.marketing_mailing_list = 'Marketing Mailing List <jgurrero@redhat.com>'
    
    email = AccountSupportContactMailer.contact_email(
      SupportContact.new({:from => test_mail_from, :to => recipient, :subject => 'test contact', :body => 'just kidding'})
    ).deliver
    assert !ActionMailer::Base.deliveries.empty?
    
    assert [recipient], email.to.inspect
    assert test_mail_from, email.from.inspect
  end
end
