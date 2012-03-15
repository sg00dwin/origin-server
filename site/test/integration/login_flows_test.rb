require 'test_helper'

class LoginFlowsTest < ActionDispatch::IntegrationTest
  
  def setup
    https!
    open_session
  end

  def internal_user
    {:login => 'test', :password => 'password'}
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
    get '/app/login'
    assert_response :success

    post_via_redirect(path, internal_user)

    assert_response :success
    assert_equal product_overview_path, path
  end
  
  test 'user should be redirected to flex app when logging in directly from the flex login' do
    get '/app/login', {}, {'HTTP_REFERER' => '/app/login/flex'}
    assert_response :success

    post(path, internal_user.merge(:redirectUrl => assigns(:redirectUrl)))
    assert_redirected_to flex_path
    puts cookies['rh_sso']
    follow_redirect!

    assert_response :success
    assert_equal flex_path, path
  end

  test 'user should be redirected to flex app when logging in directly from the flex new user' do
    get '/app/login', {}, {'HTTP_REFERER' => '/app/user/new/flex'}
    assert_response :success

    post_via_redirect(path, internal_user.merge(:redirectUrl => assigns(:redirectUrl)))

    assert_response :success
    assert_equal flex_path, path
  end
  
  test "after requesting a protected resource and logging in, the user should be redirected back to the original resource" do
    get '/app/console'
    assert_redirected_to '/app/login' 
    follow_redirect!

    post(path, internal_user)
    follow_redirect!

    assert_redirected_to '/app/console' 
  end

  test "after coming from an external resource and logging in, the user should be redirected back to the external resource" do
    get '/app/login', {}, {'HTTP_REFERER' => 'http://foo.com'}
    assert_response :success

    post(path, internal_user)
    follow_redirect!

    assert_redirected_to 'http://foo.com'
  end
  
end
