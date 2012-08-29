require File.expand_path('../../test_helper', __FILE__)

class LoginFlowsTest < ActionDispatch::IntegrationTest
  
  def setup
    https!
    open_session
  end

  def with_integrated(&block)
    previous = Rails.configuration.integrated
    Rails.configuration.integrated = true
    yield
  ensure
    Rails.configuration.integrated = previous
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
    
    ['/', '/login', '/account/new', '/account/password/new'].each do |url|
      get url, nil, {'SCRIPT_NAME' => '/app'}
      assert_response :success, "Requesting #{url}"
    end
    {
      '/user/new' => '/app/account/new',
      '/user/new/flex' => '/app/account/new',
      '/user/new/express' => '/app/account/new',
      '/express' => '/community/paas',
      '/flex' => '/community/paas',
      '/platform' => '/community/paas',
      '/getting_started' => '/community/get-started',
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

  test 'signup to app creation' do
    with_integrated do
      user = new_streamline_user

      get '/'
      assert_response :success
      assert_select 'a', :text => /sign in/i
      assert !@controller.previously_logged_in?

      get new_account_path
      assert_response :success
      assert_select 'form#new_user_form', {}, @response.inspect

      post account_path, {
        :captcha_secret => Rails.application.config.captcha_secret,
        :then => '/account',
        :web_user => {
          :email_address => user.email_address,
          :password => user.password,
          :password_confirmation => user.password,
        }
      }
      assert user = assigns(:user)
      assert user.token
      assert_redirected_to complete_account_path

      follow_redirect!
      assert_response :success
      assert_select 'p', :text => /Check your inbox/

      get email_confirm_path(:key => user.token, :emailAddress => user.email_address, :then => '/account')
      assert user = assigns(:user)
      assert_redirected_to account_path

      follow_redirect!
      assert_redirected_to new_terms_path
      assert_equal account_path, session[:terms_redirect]

      follow_redirect!
      assert_response :success
      assert_select 'form#new_term'

      post terms_path
      assert_redirected_to account_path

      follow_redirect!
      assert_response :success
      assert_equal user.login, @controller.current_user.login
      assert_equal user.ticket, @controller.current_user.ticket
      assert_select 'a', :text => user.email_address
      assert_select 'h2', :text => /personal information/i

      get logout_path
      assert_redirected_to root_path

      follow_redirect!
      assert_select 'a', :text => /sign in/i
      assert @controller.previously_logged_in?
    end
  end
end
