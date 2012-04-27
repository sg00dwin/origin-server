require File.expand_path('../../test_helper', __FILE__)

class EmailConfirmControllerTest < ActionController::TestCase

  def setup
    setup_user
  end

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
    WebUser.any_instance.expects(:confirm_email).returns(false)

    get :confirm, {:key => 'test', :emailAddress => 'test'}

    assert assigns(:user)
    assert assigns(:user).errors.empty? # stub method added none
    assert_template :error
  end

  test "success redirect to console" do
    WebUser.any_instance.expects(:confirm_email).returns(true)
    get :confirm, :key => 'test', :emailAddress => 'test'
    assert_redirected_to login_path(:email_address => 'test', :confirm_signup => true, :redirect => console_path)
  end
end
