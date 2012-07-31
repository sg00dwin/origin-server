require 'mocha'
require 'openshift'
require 'streamline'

require 'webmock/test_unit'
WebMock.allow_net_connect!

class ActiveSupport::TestCase

  def self.isolate(&block)
    self.module_eval do
      include ActiveSupport::Testing::Isolation
      setup do
        yield block
      end
    end
  end

  def self.uses_http_mock(sym=:always)
    require 'active_resource/persistent_http_mock'
    self.module_eval do
      setup{ ActiveResource::HttpMock.enabled = true } unless sym == :sometimes
      teardown do
        ActiveResource::HttpMock.reset!
        ActiveResource::HttpMock.enabled = false
      end
    end
  end
  def allow_http_mock
    ActiveResource::HttpMock.enabled = true
  end

  setup { $VERBOSE = nil }
  teardown { $VERBOSE = false }
  setup { Rails.cache.clear }

  def setup_user(unique=false)
    @user = user_to_session(WebUser.new :email_address=>"app_test1#{unique ? uuid : ''}@test1.com", :rhlogin=>"app_test1#{unique ? uuid : ''}@test1.com")
  end

  def user_to_session(user)
    session[:login] = user.login
    session[:user] = user
    session[:ticket] = user.ticket || '123'
    session[:streamline_type] = user.streamline_type
    @request.cookies['rh_sso'] = session[:ticket]
    @request.env['HTTPS'] = 'on'
    user
  end

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

  def with_config(name, value, &block)
    old = Rails.configuration.send(:"#{name}")
    Rails.configuration.send(:"#{name}=", value)
    yield
  ensure
    Rails.configuration.send(:"#{name}=", old)
  end

  def expects_integrated
    flunk 'Test requires integrated Streamline authentication' unless Rails.configuration.integrated
  end

  def gen_small_uuid()
    %x[/usr/bin/uuidgen].gsub('-', '').strip
  end

  @@name = 0
  def unique_name_format
    'name%i'
  end
  def unique_name(format=nil)
    (format || unique_name_format) % self.class.next
  end
  def self.next
    @@name += 1
  end

  @@once = []
  def once(symbol, &block)
    unless @@once.include? symbol
      @@once << symbol
      exit_block = yield block
      at_exit do
        exit_block.call if exit_block
      end
    end
  end
end

