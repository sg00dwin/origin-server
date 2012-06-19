require File.expand_path('../../test_helper', __FILE__)

class ProductControllerTest < ActionController::TestCase

  test 'should be same origin protected' do
    get :overview
    assert_response :success
    assert_equal 'SAMEORIGIN', @response.to_a[1]['X-Frame-Options'], @response.inspect
  end

  test "should show overview" do
    get :overview
    assert_response :success
  end

  test "should show getting started" do
    get :getting_started
    assert_response :success
  end

  test "should get index unauthorized" do
    get :index
    assert_response :success
  end

  test "should get index authorized" do
    get(:index, {}, {:login => "test", :ticket => "test" })
    assert :success
  end
end
