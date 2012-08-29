require File.expand_path('../../test_helper', __FILE__)

class StreamlineIntegrationTest < ActionDispatch::IntegrationTest

  def confirmed_user
    @@confirmed_user ||= begin
      user = new_streamline_user
      assert user.register('/email_confirm')
      assert user.token
      assert_nil user.login
      assert_nil user.ticket

      assert user.roles.empty?
      assert_nil user.ticket

      assert user.confirm_email
      assert_equal user.email_address, user.login
      assert_nil user.token
      assert user.ticket
      assert user.roles.include? 'simple_authenticated'

      user
    end
  end

  test 'should fail when a token is reused' do
    user = new_streamline_user
    assert user.register('/email_confirm')
    assert user.token
    assert_nil user.login
    assert_nil user.ticket

    assert user.roles.empty?
    assert_nil user.ticket

    token = user.token

    assert user.confirm_email
    assert user.errors.empty?

    user.send(:ticket=, nil)
    user.send(:token=, token)
    assert user.confirm_email
    assert user.errors.empty?
    assert_nil user.ticket

    # ensure that duplicate confirmation returns success
    assert user.register('/email_confirm'), user.errors.inspect
    assert user.errors.empty?
  end

  test 'should suppress duplicate registration' do
    user = new_streamline_user
    assert user.register('/email_confirm')
    assert user.register('/email_confirm')
  end

  test 'should return token and accept it for confirmation' do
    assert confirmed_user

    second_user = Streamline::Base.new(:ticket => confirmed_user.ticket).extend(Streamline::User)
    second_user.establish
    assert_equal confirmed_user.login, second_user.login
  end
  
  test 'should change password' do
    old_password = confirmed_user.password

    assert !confirmed_user.change_password
    assert confirmed_user.errors[:base], confirmed_user.errors.inspect

    confirmed_user.password = 'testab'
    assert !confirmed_user.change_password
    assert confirmed_user.errors[:base], confirmed_user.errors

    confirmed_user.password_confirmation = 'testab'
    assert !confirmed_user.change_password
    assert confirmed_user.errors[:base], confirmed_user.errors

    confirmed_user.old_password = old_password
    assert confirmed_user.change_password, confirmed_user.errors.inspect
    assert confirmed_user.errors.empty?

    second_user = Streamline::Base.new.extend(Streamline::User)
    second_user.authenticate!(confirmed_user.login, 'testab')
    assert second_user.ticket != confirmed_user.ticket
  end

  test 'should accept terms' do
    assert !confirmed_user.accepted_terms?
    assert confirmed_user.accept_terms
    assert confirmed_user.accepted_terms?
  end

  test 'should entitle' do
    assert !confirmed_user.waiting_for_entitle?
    assert confirmed_user.entitled?
    assert !confirmed_user.waiting_for_entitle?
  end

  test 'should change password with token' do
    #assert confirmed_user.request_password_reset('/password_reset')
    #assert user.token
  end
end
