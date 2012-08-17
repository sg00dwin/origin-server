require File.expand_path('../../test_helper', __FILE__)

class EmailConfirmControllerTest < ActionController::TestCase

  test "no parameters should error" do
    get :confirm
    assert_template :error
  end

  test "one parameter should error" do
    get :confirm, :emailAddress => 'test'
    assert_template :error
  end

  test "other parameter should error" do
    get :confirm, :key => 'test'
    assert_template :error
  end

  test "streamline returns false is an error" do
    WebUser::Mock.any_instance.expects(:confirm_email).returns(false)

    get :confirm, {:key => 'test', :emailAddress => 'test'}

    assert assigns(:user)
    assert assigns(:user).errors.empty? # stub method added none
    assert_template :error
  end

  test "success redirect to console" do
    WebUser::Mock.any_instance.expects(:confirm_email).returns(true)
    get :confirm, :key => 'test', :emailAddress => 'test'
    assert_session_user assigns(:user)
    assert_redirected_to console_path
  end

  test "should disallow external redirect" do
    WebUser::Mock.any_instance.expects(:confirm_email).returns(true)
    get :confirm, :key => 'test', :emailAddress => 'test', :then => 'http://www.google.com/foo'
    assert_redirected_to '/foo'
  end

  test "should allow relative redirect" do
    WebUser::Mock.any_instance.expects(:confirm_email).returns(true)
    get :confirm, :key => 'test', :emailAddress => 'test', :then => '/foo'
    assert_redirected_to '/foo'
  end

  test "should logout if user is currently logged in" do
    EmailConfirmController.any_instance.expects(:user_signed_in?).returns(true)
    params = {:key => 'test', :emailAddress => 'test', :then => '/foo'}
    get :confirm, params
    assert_redirected_to logout_path :cause => 'change_account', :then => email_confirm_path(params)
  end


  test "confirming user redirects to console" do
    get :confirm, :key => unconfirmed_user.token, :emailAddress => unconfirmed_user.email_address
    assert_equal unconfirmed_user.ticket, cookies['rh_sso']
    assert_session_user unconfirmed_user
    assert_redirected_to console_path
  end
end
