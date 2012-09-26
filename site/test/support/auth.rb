class ActiveSupport::TestCase
  def set_user(user)
    @request.cookies['rh_sso'] = user.ticket
    @request.env['HTTPS'] = 'on'
    @user = user
  end

  def new_streamline_user
    id = ::SecureRandom.base64(10).gsub(/[^a-zA-Z0-9_\-]/, '_')
    Streamline::Base.new(
      :email_address => "os_#{id}@mailinator.com",
      :password => ::SecureRandom.base64(20)
    ).extend(Streamline::User)
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
    session[:login] = user.login
    session[:user] = user
    session[:ticket] = user.ticket
    session[:streamline_type] = user.streamline_type if user.respond_to? :streamline_type
    super
  end
end

class ActionDispatch::IntegrationTest
  protected
    def login(user=nil)
      if user
        open_session do |sess|
          sess.https!
          sess.extend(CustomAssertions)
          sess.post login_path, :web_user => {:login => user.login, :password => user.password}
          sess.assert_response 302
        end
      else
        open_session
        https!
        self.extend(CustomAssertions)
        post login_path, :web_user => {:login => @user.login, :password => @user.password}
        assert_response 302
      end
    end
  private
    module CustomAssertions
    end
end
