require 'test_helper'

class Access::ExpressRequestControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_redirected_to login_path
  end

  test "should get success on post" do
    setup_session
    post :create
    assert assigns :access
    assert_response :success
  end
end
