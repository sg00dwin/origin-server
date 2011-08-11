require 'test_helper'
 
class LegacyFlowsTest < ActionController::IntegrationTest
  test "getting started express redirect" do
    get "/app/getting_started/express"
    follow_redirect!
    assert_equal "/app/express", path
  end

  test "getting started flex redirect" do
    get "/app/getting_started/flex"
    follow_redirect!
    assert_equal "/app/flex", path
  end

  test "access express redirect" do
    get "/app/access/express"
    follow_redirect!
    assert_equal "/app/express", path
  end

  test "access express redirect request" do
    get "/app/access/express/request"
    follow_redirect!
    assert_equal "/app/express", path
  end

  test "access express redirect request direct" do
    get "/app/access/express/request_direct"
    follow_redirect!
    assert_equal "/app/express", path
  end

  test "access flex redirect" do
    get "/app/access/flex"
    follow_redirect!
    assert_equal "/app/flex", path
  end

  test "access flex redirect request" do
    get "/app/access/flex/request"
    follow_redirect!
    assert_equal "/app/flex", path
  end
end
