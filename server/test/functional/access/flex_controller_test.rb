require 'test_helper'

class Access::FlexControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_redirected_to login_index_path
  end
  
  test "should redirect to login" do
    session[:login] = 'tester'
    post(:create, {:access_flex => {:ec2AccountNumber => '1234-1234-1234'}})
    # TODO
  end
end
