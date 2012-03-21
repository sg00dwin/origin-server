require 'test_helper'

class LoginFlowsTest < ActionDispatch::IntegrationTest
  
  def setup
    https!
    open_session
  end

  def internal_user
    {:rhlogin => 'test', :password => 'password'}
  end

  # Make sure unauthenticated users can get to basic pages
  test "browse unauthenticated pages" do
    ['/app', '/app/login', '/app/express', '/app/flex', '/app/account/new', '/app/account/password/new', '/app/partners'].each do |url|
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

  test 'user should be redirected to console when logging in directly' do
    get '/app/login'
    assert_response :success

    post(path, internal_user)
    assert_redirected_to console_path
  end
  
  test 'user should be redirected to flex app when logging in directly from the flex login' do
    get '/app/login', {}, {'HTTP_REFERER' => '/app/login/flex'}
    assert_response :success

    post(path, internal_user.merge(:redirectUrl => assigns(:redirectUrl)))
    assert_redirected_to flex_path
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

  test 'user can visit site, login, has cookies' do
    get '/app'
    assert_response :success

    get_via_redirect '/app/console'
    assert_response :success

    post_via_redirect(path, internal_user)
    assert_response :success
    #puts @request.pretty_inspect
    #puts cookies.pretty_inspect
    #assert_equal 'true', cookies['prev_login'] #FIXME Cookies BAH!
    #assert cookies['rh_sso'] #FIXME: GAAAAAH - something wierd about cookie jar URL comparison

    get('/app/account')
    assert_response :success

    get_via_redirect '/app/logout'
    assert_response :success
    assert_equal '/app', path

    assert_nil cookies['rh_sso']
    assert_equal 'true', cookies['prev_login']
  end
end
