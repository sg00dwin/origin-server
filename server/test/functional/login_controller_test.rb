require 'test_helper'

class LoginControllerTest < ActionController::TestCase
  test "should get index" do
    get :show
    assert assigns(:redirectUrl)
    assert assigns(:errorUrl)
    assert_response :success
  end

  test "should get error" do
    get :error
    assert assigns(:user)
    assert !assigns(:user).errors.empty?
    assert_response :success
  end

  test "should login and get root path" do
    post(:create, {'login' => "tester"})
    assert_equal session[:login], "tester"
    assert_not_nil session[:ticket]
    assert_redirected_to root_path
  end
end
