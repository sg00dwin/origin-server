require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  test "check credentials" do
    @controller.check_credentials
  end

  test "verify auto-request access" do
    @request.cookies['rh_sso'] = '123'
    @request.env['HTTPS'] = 'on'

    # Setup a mocked user with no terms and no access role
    user = WebUser.new
    WebUser.expects(:find_by_ticket).returns(user)
    user.expects(:establish_terms)
    user.expects(:terms).returns([])

    # First return no access, the after the request, return has access
    user.stubs(:has_access?).returns(false).then.returns(true)
    user.expects(:has_requested?).returns(false)
    user.expects(:request_access).with(CloudAccess::EXPRESS)

    # Run the check
    @controller.check_credentials

    # Make sure no notices were placed
    assert_nil flash[:notice]
  end

  test "failed auto-request access" do
    @request.cookies['rh_sso'] = '123'
    @request.env['HTTPS'] = 'on'

    # Setup a mocked user with no terms and no access role
    user = WebUser.new
    WebUser.expects(:find_by_ticket).returns(user)
    user.expects(:establish_terms)
    user.expects(:terms).returns([])

    # First return no access, the after the request, return false
    # in order to simulate a failure or queueing
    user.stubs(:has_access?).returns(false).then.returns(false)
    user.expects(:has_requested?).returns(false)
    user.expects(:request_access).with(CloudAccess::EXPRESS)

    # Run the check
    @controller.check_credentials

    # Make sure the flash notice is there about the pending account
    assert_not_nil flash[:notice]
    assert_match(/access setup/, flash[:notice])
  end

  test "no call when already has access" do
    @request.cookies['rh_sso'] = '123'
    @request.env['HTTPS'] = 'on'

    # Setup a mocked user with no terms and no access role
    user = WebUser.new
    WebUser.expects(:find_by_ticket).returns(user)
    user.expects(:establish_terms)
    user.expects(:terms).returns([])

    # Don't expect a request call if user has access
    user.stubs(:has_access?).returns(true)
    user.expects(:request_access).never()

    # Run the check
    @controller.check_credentials

    # Make sure no notices were placed
    assert_nil flash[:notice]
  end

  test "no call when already has requested access" do
    @request.cookies['rh_sso'] = '123'
    @request.env['HTTPS'] = 'on'

    # Setup a mocked user with no terms and no access role
    user = WebUser.new
    WebUser.expects(:find_by_ticket).returns(user)
    user.expects(:establish_terms)
    user.expects(:terms).returns([])

    # Don't expect a request call if user has access
    user.stubs(:has_access?).returns(false)
    user.expects(:has_requested?).returns(true)
    user.expects(:request_access).never()

    # Run the check
    @controller.check_credentials

    # Make sure the flash notice is there about the pending account
    assert_not_nil flash[:notice]
    assert_match(/access setup/, flash[:notice])
  end
end
