require File.expand_path('../../test_helper', __FILE__)

class WebUserTest < ActiveSupport::TestCase
  STREAMLINE_USER = "mhicks+login@redhat.com"
  RH_USER = "tawood3"
  PWD = "redhat"
  AMZ_ACCT = "5314-1588-3065"  # mmcgrath@redhat.com account

  test "serialization" do
    user1 = WebUser.new(:email_address => STREAMLINE_USER, :password => PWD)
    str = user1.to_json
    user2 = WebUser.from_json(str)
    assert user1.email_address == user2.email_address
  end

  test "mixin" do
    assert WebUser.new.respond_to?(:register)
  end

  test "login and rhlogin are identical" do
    user = WebUser.new(:rhlogin => 'bob')
    assert_equal user.rhlogin, user.login
  end

  test "protect rhlogin" do
    s = Class.new(Streamline::Base) do
      include Streamline::User
      def initialize(login)
        self.rhlogin = login
      end
      def set=(login)
        self.rhlogin = login
      end
    end
    s = s.new "test"
    assert_equal "test", s.rhlogin

    assert_raise RuntimeError do
      s.set = "another"
    end

    s = Class.new(Streamline::Base) do
      include Streamline::User
      include Streamline::Mock
      def initialize(login)
        self.rhlogin = login
      end
      def set=(login)
        self.rhlogin = login
      end
    end
    s = s.new "test"

    assert_equal "test", s.rhlogin

    assert_raise RuntimeError do
      s.set = "another"
    end
  end

  test "should instantiate mock by default" do
    assert WebUser.new.mock?
    assert WebUser.mock?
    assert !WebUser::Integrated.new.mock?
    assert !WebUser::Integrated.mock?
    assert WebUser::Mock.new.mock?
    assert WebUser::Mock.mock?
  end


  test "get simple identity" do
    user = WebUser.new.authenticate!('bob@bob.com', 'password')
    identities = Identity.find(user)
    assert_equal 1, identities.length
    assert_equal :openshift, identities[0].type
    assert_equal user.login, identities[0].id
  end

  test "get rhn identity" do
    user = WebUser.new.authenticate!('bob', 'password')
    identities = Identity.find(user)
    assert_equal 1, identities.length
    assert_equal :red_hat, identities[0].type
    assert_equal user.login, identities[0].id
  end

  test 'logout should delete the token' do
    assert user = WebUser.new
    assert_nil user.api_ticket
    user.api_ticket = 'foo'
    Authorization.expects(:destroy).with('foo', :as => user).returns(true)
    user.logout
  end

  test 'logout should eat exceptions' do
    assert user = WebUser.new
    assert_nil user.api_ticket
    user.api_ticket = 'foo'
    Authorization.expects(:destroy).with('foo', :as => user).raises(StandardError)
    Rails.logger.expects(:warn)
    user.logout
  end

  test 'email from prohibited domain is not valid' do
    Rails.application.config.expects(:prohibited_email_domains).returns(['banneddomain.com'])
    user = WebUser.new(:email_address => 'someguy@banneddomain.com', :password => PWD)

    assert !user.valid?
    assert user.errors.values.flatten.include? 'OpenShift does not allow creating accounts with email addresses from anonymous mail services due to security concerns. Please use a different email address.'
  end

  test 'email from prohibited subdomain is not valid' do
    Rails.application.config.expects(:prohibited_email_domains).returns(['onebad.net', 'banneddomain.com'])
    user = WebUser.new(:email_address => 'someguy@foo.banneddomain.com', :password => PWD)

    assert !user.valid?
    assert user.errors.values.flatten.include? 'OpenShift does not allow creating accounts with email addresses from anonymous mail services due to security concerns. Please use a different email address.'
  end

  test 'email from domain with prohibited domain as substring is valid' do
    Rails.application.config.expects(:prohibited_email_domains).returns(['onebad.net', 'banneddomain.com'])
    user = WebUser.new(:email_address => 'someguy@notabanneddomain.com', :password => PWD)

    assert user.valid?
  end
end
