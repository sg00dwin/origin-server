require 'test_helper'
require 'rubygems'
require 'net/http'
require 'json'

class WebUserTest < ActiveSupport::TestCase
  STREAMLINE_USER = "mhicks+login@redhat.com"
  RH_USER = "tawood3"
  PWD = "redhat"
  AMZ_ACCT = "5314-1588-3065"  # mmcgrath@redhat.com account

  test "serialization" do
    user1 = WebUser.new(:emailAddress => STREAMLINE_USER, :password => PWD)
    str = user1.to_json
    user2 = WebUser.from_json(str)
    assert user1.emailAddress == user2.emailAddress
  end

  test "streamline user login" do
    user = WebUser.new(:emailAddress => STREAMLINE_USER, :password => PWD)
    user.login

    assert user.ticket
  end

  test "streamline user roles" do
    user = WebUser.new(:emailAddress => STREAMLINE_USER, :password => PWD)
    user.login

    assert user.roles.length > 0
    assert user.roles.index("simple_authenticated")
    assert !user.roles.index("authenticated")
  end

  test "legacy user login" do
    user = WebUser.new(:emailAddress => RH_USER, :password => PWD)

    user.login

    assert user.ticket
  end

  test "legacy user roles" do
    user = WebUser.new(:emailAddress => RH_USER, :password => PWD)

    user.login

    assert user.roles.length > 0
    assert user.roles.index("authenticated")
    assert !user.roles.index("simple_authenticated")
  end

  test "registration" do
    login = get_unique_username
    user = WebUser.new(:emailAddress => login, :password => PWD)

    user.register("http://www.example.org")
  end

  test "find by ticket" do
    assert WebUser.find_by_ticket("test")
  end

  test "request express access" do
    user = WebUser.new(:emailAddress => RH_USER, :password => PWD)
    user.login

    solution = CloudAccess::EXPRESS
    user.request_access(solution, AMZ_ACCT)
    assert user.has_access?(solution) or user.has_requested?(solution)
  end

  test "register integrated" do
    user = WebUser.new(:emailAddress => RH_USER, :password => PWD)

    # Mock out the HTTP call
    res_mock = mock('Net::HTTPResponse')
    res_mock.stubs(:code => '200',
                   :message => "OK",
                   :content_type => "text/html",
                   :body => nil)
    Net::HTTP.any_instance.expects(:start).returns(res_mock)

    user.register_integrated("test")
  end

  test "http call" do
    res = Net::HTTPSuccess.new('1.1', '200', 'test')
    res.expects(:body).returns(nil)
    Net::HTTP.any_instance.expects(:start).returns(res)

    WebUser.new.http_post(URI.parse("https://localhost/"))
  end
end
