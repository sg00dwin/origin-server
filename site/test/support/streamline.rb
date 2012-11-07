require 'streamline'

class ActiveSupport::TestCase

  def omit_on_register
    omit('Streamline did not successfully register a new user, environment may be down')
  end

  def assert_session_user(user)
    assert_equal user.login, session[:login]
    assert_equal user.ticket, session[:ticket]
    assert_equal user.ticket, cookies['rh_sso']
    assert_equal user.streamline_type, session[:streamline_type]
  end

  def unconfirmed_user
    @unconfirmed_user ||= begin
      user = new_streamline_user
      omit_on_register unless user.register('/email_confirm')
      assert user.token
      user
    end
  end

  def full_user_args(user=nil, delete_keys=[])
    args = {
      :login => 'test1',
      :password => 'p4ssw0rd',
      :password_confirmation => 'p4ssw0rd',
      :email_subscribe => false,
      :greeting => 'Mr.',
      :first_name => 'Joe',
      :last_name => 'Somebody',
      :phone_number => '9191111111',
      :company => 'Test Corp.',
      :address1 => '12345 Happy Street',
      :city => 'Happyville',
      :country => 'US',
      :state => 'TX',
      :postal_code => '10001',
    }
    unless user.nil?
      args[:login] = user.email_address
      args[:password] = user.password
      args[:password_confirmation] = user.password
    end
    delete_keys.each do |key|
      args.delete(key)
    end
    args
  end

end

