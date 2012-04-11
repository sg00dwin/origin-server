require File.expand_path('../../test_helper', __FILE__)

class ProductControllerTest < ActionController::TestCase
  
  test "should show overview" do
    get :overview
    assert_response :success
  end

  test "should show getting started" do
    get :getting_started
    assert_response :success
  end

end
