require 'test_helper'

class Access::ExpressControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_redirected_to login_index_path
  end

  test "should get success on post" do
    session[:login] = 'tester'
    post(:create, {})
    assert_response :success
  end
end
