require 'test_helper'

class Access::ExpressControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_redirected_to login_path
  end
end
