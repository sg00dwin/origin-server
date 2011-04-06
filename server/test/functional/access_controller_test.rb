require 'test_helper'

class AccessControllerTest < ActionController::TestCase
  setup do
    @controller = Access::ExpressController.new
  end
  test "should get index" do
    get :index
    assert_response :success
  end

end
