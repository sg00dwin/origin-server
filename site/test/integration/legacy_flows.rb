require 'test_helper'
 
class LegacyFlowsTest < ActionDispatch::IntegrationTest
  test "getting started express redirect" do
    get "/app/getting_started/express"
    follow_redirect!
    assert_equal "/app/getting_started", path
  end

	test "should create new express user" do
		get_via_redirect '/app/user/new/express'
		assert_equal '/app/user/new', path
	end
	
  test "confirm express redirect" do
    test_query = {:key => 'test', :emailAddress => 'test@test.com'}
    get '/app/email_confirm_express', test_query
    follow_redirect!
    assert_equal '/app/email_confirm', path
    assert_equal test_query.stringify_keys!, request.query_parameters
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

end
