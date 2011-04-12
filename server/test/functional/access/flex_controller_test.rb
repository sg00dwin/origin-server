require 'test_helper'

class Access::FlexControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_redirected_to login_index_path
  end
  
  test "should get error with invalid ec2 account number" do
    session[:login] = 'tester'
    post(:create, {:access_flex => {:ec2AccountNumber => '123-123-123'}})
    assert assigns(:access_flex)
    assert assigns(:access_flex).errors.has_key?(:ec2AccountNumber)
    assert_response :success
  end
  
  test "should get success on post" do
    session[:login] = 'tester'
    post(:create, {:access_flex => {:ec2AccountNumber => '1234-1234-1234'}})
    assert_response :success
  end
end
