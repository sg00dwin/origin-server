require 'test_helper'

class Access::FlexRequestControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_redirected_to login_path
  end

  test "should get error with invalid ec2 account number" do
    setup_session
    post(:create, {:access_flex_request => {:ec2_account_number => '123-123-123'}})
    assert assigns(:access)
    assert assigns(:access).errors[:ec2_account_number].length > 0
    assert_response :success
  end

  test "should get success on post" do
    setup_session
    post(:create, {:access_flex_request => {:ec2_account_number => '1234-1234-1234'}})
    assert_response :success
  end
end
