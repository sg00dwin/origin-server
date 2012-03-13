require 'test_helper'

class LoginFlowsTest < ActionDispatch::IntegrationTest
  
  def setup
    https!
    open_session
  end

  # # Make sure unauthenticated users can get to basic pages
  # test "browse unauthenticated pages" do
    # [root_path, login_path, express_path, flex_path, new_account_path, new_password_path, partners_path].each do |url|
      # get url
      # assert_response :success, "Requesting #{url}"
    # end
  # end
# 
  # # Make sure users are sent to the login controller when requesting 
  # # a protected page
  # test 'test being redirected to the login controller' do
    # [control_panel_path, edit_password_path, web_user_path, account_path].each do |url|
      # get url
      # assert_redirected_to login_path, "Requesting #{url}"
    # end
  # end
# 
  # test 'user should be redirected to product overview when logging in directly' do
    # get login_path
    # assert_response :success
# 
    # post_via_redirect(path, {:login => 'testuser', :redirectUrl => root_path })
# 
    # assert_response :success
    # assert_equal path, product_overview_path
  # end
#   
  # test 'user should be redirected to flex app when logging in directly from the flex login' do
    # get login_path, {}, {'HTTP_REFERER' => '/app/login/flex'}
    # assert_response :success
# 
    # post_via_redirect(path, {:login => 'testuser', :redirectUrl => root_path })
# 
    # assert_response :success
    # assert_equal path, flex_path
  # end
#   
  # test 'user should be redirected to express app when logging in directly from the express login' do
    # get login_path, {}, {'HTTP_REFERER' => '/app/login/express'}
    # assert_response :success
#   
    # post_via_redirect(path, {:login => 'testuser', :redirectUrl => root_path })
#   
    # assert_response :success
    # assert_equal path, express_path
  # end
#   
  # test 'user should be redirected to flex app when logging in directly from the flex new user' do
    # get login_path, {}, {'HTTP_REFERER' => '/app/user/new/flex'}
    # assert_response :success
#   
    # post_via_redirect(path, {:login => 'testuser', :redirectUrl => root_path })
#   
    # assert_response :success
    # assert_equal path, flex_path
  # end
#   
  # test 'user should be redirected to express app when logging in directly from the express new user' do
    # get login_path, {}, {'HTTP_REFERER' => '/app/user/new/express'}
    # assert_response :success
#   
    # post_via_redirect(path, {:login => 'testuser', :redirectUrl => root_path })
#   
    # assert_response :success
    # assert_equal path, express_path
  # end
#   
  # test "after requesting a protected resource and logging in, the user should be redirected back to the original resource" do
    # get control_panel_path
    # assert_redirected_to login_path
    # follow_redirect!
# 
    # post(path, {:login => 'testuser', :redirectUrl => root_path})
    # follow_redirect!
# 
    # assert_redirected_to control_panel_path
  # end
# 
  # test "after coming from an external resource and logging in, the user should be redirected back to the external resource" do
    # get login_path, {}, {'HTTP_REFERER' => 'http://foo.com'}
    # assert_response :success
# 
    # post(path, {:login => 'testuser', :redirectUrl => root_path})
    # follow_redirect!
# 
    # assert_redirected_to 'http://foo.com'
  # end
  
end
