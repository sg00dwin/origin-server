require 'test_helper'

class Access::FlexControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_redirected_to login_index_path
  end
  
  test "should get error with invalid ec2 account number" do
    session[:login] = 'tester'
    form = get_post_form
    form[:ec2_account_number] = '123-123-123'
    post(:create, {:access_flex => form})
    assert assigns(:access_flex)
    assert assigns(:access_flex).errors[:ec2_account_number].length > 0
    assert_response :success
  end
  
  test "should get error without accepting terms" do
    session[:login] = 'tester'
    form = get_post_form
    form[:terms_accepted] = nil
    post(:create, {:access_flex => form})
    assert assigns(:access_flex)
    assert assigns(:access_flex).errors[:terms_accepted].length > 0
    assert_response :success
  end
  
  test "should get success on post" do
    session[:login] = 'tester'
    form = get_post_form
    post(:create, {:access_flex => form})
    assert_response :success
  end
  
  def get_post_form
    {:ec2_account_number => '1234-1234-1234', :terms_accepted => 'on'}
  end
  
end
