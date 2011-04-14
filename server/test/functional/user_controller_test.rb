require 'test_helper'

class UserControllerTest < ActionController::TestCase
  test "should get new unauthorized" do
    get :new
    assert_response :success
  end

  test "should get too short password error" do
    session[:login] = 'tester'
    form = get_post_form
    form[:password]='short'
    post(:create, {:web_user => form})
    assert assigns(:user)
    assert assigns(:user).errors[:password].length > 0
    assert_response :success
  end
  
  test "should get password must match error" do
    session[:login] = 'tester'
    form = get_post_form
    form[:password]='doesntmatch'
    post(:create, {:web_user => form})
    assert assigns(:user)
    assert assigns(:user).errors[:password].length > 0
    assert_response :success
  end
  
  test "should get invalid email address" do
    session[:login] = 'tester'
    form = get_post_form
    form[:email_address]='notreallyanemail'
    post(:create, {:web_user => form})
    assert assigns(:user)
    assert assigns(:user).errors[:email_address].length > 0
    assert_response :success
  end
  
  test "should get invalid email address domain" do
    session[:login] = 'tester'
    form = get_post_form
    form[:email_address]='test@example.ir'
    post(:create, {:web_user => form})
    assert assigns(:user) 
    assert assigns(:user).errors[:email_address].length > 0
    assert_response :success
  end
  
  test "should get missing fields" do
    session[:login] = 'tester'
    post(:create, {:web_user => {}})
    assert assigns(:user)
    assert assigns(:user).errors[:email_address].length > 0
    assert assigns(:user).errors[:password].length > 0
    assert_response :success
  end
  
  test "should get success on post" do
    session[:login] = 'tester'
    post(:create, {:web_user => get_post_form})
    assert_response :success
  end
  
  def get_post_form
    {:email_address => 'tester@example.com', :password => 'pw1234', :password_confirmation => 'pw1234', :terms_accepted => 'on'}
  end
end
