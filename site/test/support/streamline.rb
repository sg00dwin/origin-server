require 'streamline'

class ActiveSupport::TestCase

  def assert_session_user(user)
    assert_equal user.login, session[:login]
    assert_equal user.ticket, session[:ticket]
    assert_equal user.ticket, cookies['rh_sso']
    assert_equal user.streamline_type, session[:streamline_type]
  end

  def new_user
    id = ActiveSupport::SecureRandom.base64(10).gsub(/[^a-zA-Z0-9_\-]/, '_')
    Streamline::Base.new(
      :email_address => "os_#{id}@mailinator.com",
      :password => ActiveSupport::SecureRandom.base64(20)
    ).extend(Streamline::User)
  end

  def unconfirmed_user
    @unconfirmed_user ||= begin
      user = new_user
      assert user.register('/email_confirm')
      assert user.token
      user
    end
  end

end

