require 'test_helper'

class Access::ExpressRequestControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_redirected_to login_path
  end

  test "should get success on post" do
    session[:login] = 'tester'
    form = get_post_form
    post(:create, {:access_express_request => form})
    assert assigns(:access)
    assert_response :success
  end
  
  test "should get error without accepting terms" do
    session[:login] = 'tester'
    form = get_post_form
    form[:terms_accepted] = nil
    post(:create, {:access_express_request => form})
    assert assigns(:access)
    assert assigns(:access).errors[:terms_accepted].length > 0
    assert_response :success
  end  
  
  def get_post_form
    {:terms_accepted => 'on', :accepted_terms_list => {'1','2','3','4'}}
  end
end
