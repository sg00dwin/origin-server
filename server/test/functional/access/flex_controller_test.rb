require 'test_helper'

class Access::FlexControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_redirected_to login_index_path
  end
end
