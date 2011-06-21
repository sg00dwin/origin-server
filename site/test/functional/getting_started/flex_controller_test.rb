require 'test_helper'

class GettingStarted::FlexControllerTest < ActionController::TestCase
  test "should get index unauthorized" do
    get :show
    assert_redirected_to login_path
  end
end
