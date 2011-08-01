require 'test_helper'

class Access::ExpressRequestControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_redirected_to login_path
  end
  
  test "should get success on new if logged in with no roles" do
    setup_session
    get :new
    assert_response :success
  end
  
  test "should render already requested view if access already requested" do
    setup_session CloudAccess.req_role(CloudAccess::EXPRESS)
    get :new
    assert_select '#errors_div p', /already requested access/
  end
  
  test "should get getting_started page if already have access" do
    setup_session CloudAccess.auth_role(CloudAccess::EXPRESS)
    get :new
    assert_redirected_to getting_started_path
  end
  
  test "should get success on post" do
    setup_session
    post :create
    assert assigns :access
    assert_response :success
  end
end
