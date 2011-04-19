require 'test_helper'

class GettingStarted::GenericControllerTest < ActionController::TestCase
  test "should get index unauthorized" do
    get :show
    assert_response :success
  end
end
