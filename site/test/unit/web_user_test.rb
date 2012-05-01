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

  test "find by ticket" do
    assert WebUser.find_by_ticket("1234")
  end

  test "find by ticket throws" do
    WebUser.any_instance.stubs(:establish) { @rhlogin = nil }
    assert_raise(AccessDeniedException) { WebUser.find_by_ticket("1234") }
  end

  test "login and rhlogin are identical" do
    user = WebUser.new(:rhlogin => 'bob')
    assert_equal user.rhlogin, user.login
  end

  test "protect rhlogin" do
    s = Class.new(Streamline::User) do
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

    s = Class.new(Streamline::User) do
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
end
