require 'test_helper'

class Access::FlexRequestControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_redirected_to login_path
  end

  test "should get success on post" do
    setup_session
    post(:create, {})
    assert_response :success
  end
end
