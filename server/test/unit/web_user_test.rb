require 'test_helper'

class WebUserTest < ActiveSupport::TestCase
  STREAMLINE_USER = "mhicks+login@redhat.com"
  RH_USER = "tawood3"
  PWD = "redhat"
  AMZ_ACCT = "5314-1588-3065"  # mmcgrath@redhat.com account

  test "streamline user login" do
    user = WebUser.new(:emailAddress => STREAMLINE_USER, :password => PWD)
    user.login

    assert user.ticket != nil
  end

  test "streamline user roles" do
    user = WebUser.new(:emailAddress => STREAMLINE_USER, :password => PWD)
    user.login

    assert user.roles.length > 0
    assert user.roles.index("simple_authenticated") != -1
    assert user.roles.index("authenticated") == nil
  end

  test "legacy user login" do
    user = WebUser.new(:emailAddress => RH_USER, :password => PWD)

    user.login

    assert user.ticket != nil
  end

  test "legacy user roles" do
    user = WebUser.new(:emailAddress => RH_USER, :password => PWD)

    user.login

    assert user.roles.length > 0
    assert user.roles.index("authenticated") != -1
    assert user.roles.index("simple_authenticated") == nil
  end

  test "requesting Express access" do
    result = get_unique_username

    # Note - the below code works but you can only request access once
    # TODO - register a new user
    # TODO - validate their email address (not sure how yet)
    #user = WebUser.new(:emailAddress => result[:login], :password => PWD)
    #user.login
    #
    #solution = CloudAccess::EXPRESS
    #user.request_access(solution, AMZ_ACCT)
    #assert user.is_auth?(solution) or user.has_requested?(solution)
  end

  test "request Express access twice" do
    # TODO - test this and handle the 500
  end
end
