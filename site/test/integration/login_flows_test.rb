require File.expand_path('../../test_helper', __FILE__)

class LoginFlowsTest < ActionDispatch::IntegrationTest
  
  def setup
    https!
    open_session
  end

  def internal_user
    {:rhlogin => 'test', :password => 'password'}
  end

  test "basic site redirection works for subsites" do
    get '/user/new'
    assert_redirected_to '/account/new'
  end
  test "basic site redirection works with real sites" do
    get '/user/new', nil, {'SCRIPT_NAME' => '/app'}
    assert_redirected_to '/app/account/new'
  end

  # Make sure unauthenticated users can get to basic pages
  test "browse unauthenticated pages" do
    
    ['/', '/login', '/account/new', '/account/password/new', '/partners'].each do |url|
      get url, nil, {'SCRIPT_NAME' => '/app'}
      assert_response :success, "Requesting #{url}"
    end
    {
      '/user/new' => '/app/account/new',
      '/user/new/flex' => '/app/account/new',
      '/user/new/express' => '/app/account/new',
      '/express' => '/app/platform',
      '/flex' => '/app/platform'
    }.each_pair do |url,to|
      get url, nil, {'SCRIPT_NAME' => '/app'}
      assert_redirected_to to, "Requesting #{url} => #{to}"
    end
  end

  # Make sure users are sent to the login controller when requesting 
  # a protected page
  test 'test being redirected to the login controller' do
    ['/console'].each do |url|
      get url
      assert_redirected_to login_path(:redirectUrl => url), "Requesting #{url}"
    end
  end

  test 'user should be redirected to console when logging in directly' do
    get '/login'
    assert_response :success

    post(path, internal_user)
    assert_redirected_to console_path
  end
  
  test 'user can visit site, login, has cookies' do
    get '/'
    assert_response :success

    get_via_redirect '/console'
    assert_response :success

    post_via_redirect(path, internal_user)
    assert_response :success
    #puts @request.pretty_inspect
    #puts cookies.pretty_inspect
    #assert_equal 'true', cookies['prev_login'] #FIXME Cookies BAH!
    #assert cookies['rh_sso'] #FIXME: GAAAAAH - something wierd about cookie jar URL comparison

    get('/account')
    assert_response :success

    get_via_redirect '/logout'
    assert_response :success
    assert_equal '/', path

    assert_blank cookies['rh_sso']
    assert_equal 'true', cookies['prev_login']
  end
end
