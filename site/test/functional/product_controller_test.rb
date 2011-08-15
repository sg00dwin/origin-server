require 'test_helper'

class ProductControllerTest < ActionController::TestCase
  test "express" do
    get :express
    assert_response :success
  end

  test "flex" do
    get :flex
    assert_response :success
  end
  
  test "express with confirm email" do
    session[:confirm_flow] = true
    get :express
    assert_redirected_to login_path
    assert_not_nil flash[:notice]
    assert_nil session[:confirm_flow]
  end

  test "flex with confirm email" do
    session[:confirm_flow] = true
    get :flex
    assert_redirected_to login_path
    assert_not_nil flash[:notice]
    assert_nil session[:confirm_flow]
  end

end
