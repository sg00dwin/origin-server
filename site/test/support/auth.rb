class ActiveSupport::TestCase
  class TestWebUser < Streamline::Base
    def promote(streamline_hash)
      streamline_hash[:login] = self.login
      self.roles = ['authenticated','mock_user']
      self.full_user?
    end
  end

  def new_streamline_user
    id = ::SecureRandom.base64(10).gsub(/[^a-zA-Z0-9_\-]/, '_')
    Streamline::UserContext.new(TestWebUser.new(
      :email_address => "os_#{id}@mailinator.com",
      :password => ::SecureRandom.base64(20)
    ))
  end
end

class ActionController::TestCase
  def new_user(opts=nil)
    if opts
      opts[:ticket] = '1234'
      opts[:password] = nil
    end
    WebUser::Mock.new opts
  end

  def set_user(user)
    user_to_session(user, session)
    super
  end

  def user_to_session(user, ses={})
    ses[:login] = user.login
    ses[:ticket] = user.ticket
    ses[:api_ticket] = user.api_ticket if user.respond_to? :api_ticket
    ses[:streamline_type] = user.streamline_type if user.respond_to? :streamline_type
    ses
  end
end

class ActionDispatch::IntegrationTest
  protected
    def user_env
      # Empty stub
    end
    def set_user(user)
      @user = user
    end
    def login(user=nil, expected=302)
      if user
        open_session do |sess|
          sess.https!
          sess.extend(CustomAssertions)
          sess.post login_path, :web_user => {:login => user.login, :password => user.password}
          sess.assert_response expected if expected
        end
      else
        open_session
        https!
        self.extend(CustomAssertions)
        post login_path, :web_user => {:login => @user.login, :password => @user.password}
      end
    end
  private
    module CustomAssertions
    end
end
