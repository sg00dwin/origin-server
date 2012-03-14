require 'test_helper'

class LoginFlowsTest < ActionDispatch::IntegrationTest
  
  def setup
    https!
    open_session
  end

  # Make sure unauthenticated users can get to basic pages
  test "browse unauthenticated pages" do
    ['/app', '/app/login', '/app/express', '/app/flex', '/app/account/new', '/app/user/request_password_reset_form', '/app/partners'].each do |url|
      get url
      assert_response :success, "Requesting #{url}"
    end
  end

  # Make sure users are sent to the login controller when requesting 
  # a protected page
  test 'test being redirected to the login controller' do
    ['/app/console'].each do |url|
      get url
      assert_redirected_to login_path, "Requesting #{url}"
    end
  end

  test 'user should be redirected to product overview when logging in directly' do
    get '/app/login' #TODO: fix to use login_path
    assert_response :success

    post_via_redirect(path, {:login => 'testuser', :redirectUrl => root_path })

    assert_response :success
    assert_equal path, product_overview_path
  end
  
  test 'user should be redirected to flex app when logging in directly from the flex login' do
    get '/app/login', {}, {'HTTP_REFERER' => '/app/login/flex'} #TODO: fix to use login_path
    assert_response :success

    post_via_redirect(path, {:login => 'testuser', :redirectUrl => root_path })

    assert_response :success
    assert_equal path, flex_path
  end
  
  test 'user should be redirected to express app when logging in directly from the express login' do
    get '/app/login', {}, {'HTTP_REFERER' => '/app/login/express'} #TODO: fix to use login_path
    assert_response :success
  
    post_via_redirect(path, {:login => 'testuser', :redirectUrl => root_path })
  
    assert_response :success
    assert_equal path, express_path
  end
  
  test 'user should be redirected to flex app when logging in directly from the flex new user' do
    get '/app/login', {}, {'HTTP_REFERER' => '/app/user/new/flex'} #TODO: fix to use login_path
    assert_response :success
  
    post_via_redirect(path, {:login => 'testuser', :redirectUrl => root_path })
  
    assert_response :success
    assert_equal path, flex_path
  end
  
  test 'user should be redirected to express app when logging in directly from the express new user' do
    get '/app/login', {}, {'HTTP_REFERER' => new_web_user_path} #TODO: fix to use login_path
    assert_response :success
  
    post_via_redirect(path, {:login => 'testuser', :redirectUrl => root_path })
  
    assert_response :success
    assert_equal path, express_path
  end
  
  test "after requesting a protected resource and logging in, the user should be redirected back to the original resource" do
    get '/app/console' #TODO: fix to use console_path
    assert_redirected_to '/app/login' #TODO: fix to use login_path
    follow_redirect!

    post(path, {:login => 'testuser', :redirectUrl => root_path})
    follow_redirect!

    assert_redirected_to '/app/console' #TODO: fix to use login_path
  end

  test "after coming from an external resource and logging in, the user should be redirected back to the external resource" do
    get '/app/login', {}, {'HTTP_REFERER' => 'http://foo.com'} #TODO: fix to use login_path
    assert_response :success

    post(path, {:login => 'testuser', :redirectUrl => root_path})
    follow_redirect!

    assert_redirected_to 'http://foo.com'
  end
  
end
