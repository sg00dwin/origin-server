require 'test_helper'

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
    login = "jdoe"
    WebUser.any_instance.expects(:establish)
    user = WebUser.find_by_ticket("1234")
  end
end
