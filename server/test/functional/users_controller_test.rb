require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get index unauthorized" do
    get :index
    assert_response :success
  end

  test "should get error too short password" do
    session[:login] = 'tester'
    form = get_post_form
    form[:password]='short'
    post(:create, {:web_user => form})
    assert assigns(:user)
    assert assigns(:user).errors.has_key?(:password)
    assert_response :success
  end
  
  test "should get success on post" do
    session[:login] = 'tester'
    post(:create, {:web_user => get_post_form})
    assert_response :success
  end
  
  def get_post_form
    {:emailAddress => 'tester@example.com', :password => 'pw1234', :passwordConfirmation => 'pw1234', :termsAccepted => '1'}
  end
end
