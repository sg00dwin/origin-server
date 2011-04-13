require 'test_helper'

class Access::ExpressControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_redirected_to login_index_path
  end

  test "should get success on post" do
    session[:login] = 'tester'
    form = get_post_form
    post(:create, {:access_express => form})
    assert assigns(:access_express)
    assert_response :success
  end
  
  test "should get error without accepting terms" do
    session[:login] = 'tester'
    form = get_post_form
    form[:terms_accepted] = nil
    post(:create, {:access_express => form})
    assert assigns(:access_express)
    assert assigns(:access_express).errors[:terms_accepted].length > 0
    assert_response :success
  end  
  
  def get_post_form
    {:terms_accepted => 'on'}
  end
end
