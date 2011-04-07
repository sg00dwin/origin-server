require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get index unauthorized" do
    get :index
    assert_response :success
  end

  test "should get getting_started" do
    get :getting_started
    assert_response :success
  end

  test "should be workflow redirected" do
    get(:index, {}, {:workflow => protected_path })
    assert_redirected_to protected_path

    assert_nil session[:workflow]
  end

  test "should get index authorized" do
    get(:index, {}, {:login => "test", :ticket => "test" })
    assert_redirected_to protected_path
  end
end
