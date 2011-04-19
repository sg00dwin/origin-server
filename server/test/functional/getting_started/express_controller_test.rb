require 'test_helper'

class GettingStarted::ExpressControllerTest < ActionController::TestCase
  test "should get index unauthorized" do
    get :show
    assert_response :success
  end
end
