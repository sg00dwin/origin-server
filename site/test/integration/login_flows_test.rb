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

  def internal_user_2
    {:rhlogin => 'test2', :password => 'password'}
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

    ['/login', '/account/new', '/account/password/new'].each do |url|
      get url, nil, {'SCRIPT_NAME' => '/app'}
      assert_response :success, "Requesting #{url}"
    end
    {
      '/user/new' => '/app/account/new',
      '/user/new/flex' => '/app/account/new',
      '/user/new/express' => '/app/account/new',
      '/express' => community_base_url('paas'),
      '/flex' => community_base_url('paas'),
      '/platform' => community_base_url('paas'),
      '/getting_started' => community_base_url('get-started'),
    }.each_pair do |url,to|
      get url, nil, {'SCRIPT_NAME' => '/app'}
      assert_redirected_to to, "Requesting #{url} => #{to}"
    end
  end

  # Make sure users are sent to the login controller when requesting
  # a protected page
  test 'test being redirected to the login controller' do
    ['/console', '/console/applications?test=bar'].each do |url|
      get url
      assert_redirected_to login_path(:then => url), "Requesting #{url}"
    end
  end

  test 'user should be redirected to console when logging in directly' do
    get '/login'
    assert_response :success

    post(path, internal_user)
    assert_redirected_to console_path
  end

  test 'logins with the same session should reset the sesion' do
    post('/login', internal_user)
    assert_redirected_to console_path

    assert original_id = session['session_id']

    post('/login', internal_user_2)
    assert_redirected_to console_path

    assert new_id = session['session_id']
    assert_not_equal original_id, new_id
  end

  test 'user can visit site, login, has cookies' do
    get '/'
    assert_redirected_to community_url

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

    get '/logout'
    assert_redirected_to root_path

    get root_path
    assert_redirected_to community_url

    assert_blank cookies['rh_sso']
    assert_equal 'true', cookies['prev_login']
  end

  test 'signup to app creation' do
    omit_if_aria_is_unavailable
    with_integrated do
      user = new_streamline_user

      get '/'
      assert_redirected_to community_url

      assert !@controller.previously_signed_in?

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
      assert user.valid?, user.errors.inspect
      omit_on_register unless user.token
      assert_redirected_to complete_account_path

      follow_redirect!
      assert_response :success
      assert_select 'p', :text => /Check your inbox/

      get email_confirm_path(:key => user.token, :emailAddress => user.email_address)
      assert user = assigns(:user)
      assert_redirected_to welcome_account_path

      follow_redirect!
      assert_redirected_to new_terms_path
      assert_equal welcome_account_path, session[:terms_redirect]

      follow_redirect!
      assert_response :success
      assert_select 'form#new_term'

      post terms_path
      assert_redirected_to welcome_account_path

      follow_redirect!
      assert_redirected_to getting_started_path

      get account_path
      assert_response :success
      assert_equal user.login, @controller.current_user.login
      assert_equal user.ticket, @controller.current_user.ticket
      assert_select 'a', :text => user.email_address
      assert_select 'h2', :text => /Common Questions/i

      get logout_path
      assert_redirected_to root_path

      follow_redirect!
      assert_redirected_to community_url
      #assert_select 'a', :text => /sign in/i
      assert @controller.previously_signed_in?
    end
  end

  test 'ensure new user is queued properly' do
    with_integrated do
      user = unconfirmed_user
      assert user.confirm_email
      assert user.accept_terms

      WebUser::Integrated.any_instance.expects(:roles).at_least_once.returns(['cloud_access_request_1', 'simple_authenticated'])

      set_user(user)
      login
      assert_response :success
      assert_template :pending
      assert_select 'h1', "You're in the queue!"

      get console_path
      assert_response :success
      assert_template :pending
      assert_select 'h1', "You're in the queue!"
    end
  end

  test 'ensure new user catches streamline error properly' do
    with_integrated do
      user = unconfirmed_user
      assert user.confirm_email
      assert user.accept_terms

      WebUser::Integrated.any_instance.expects(:entitled?).at_least_once.returns(false)
      WebUser::Integrated.any_instance.expects(:waiting_for_entitle?).at_least_once.returns(true)

      set_user(user)
      login
      assert_response :success
      assert_template :pending
      assert_select 'h1', "You're in the queue!"

      get console_path
      assert_response :success
      assert_template :pending
      assert_select 'h1', "You're in the queue!"
    end
  end

  test 'prohibited email address is rejected' do
    with_integrated do
      Rails.application.config.expects(:prohibited_email_domains).returns(['prohibitedemail.net'])
      get new_account_path
      assert_response :success
      assert_select 'form#new_user_form', {}, @response.inspect

      post account_path, {
        :captcha_secret => Rails.application.config.captcha_secret,
        :then => '/account',
        :web_user => {
          :email_address => 'bob@prohibitedemail.net',
          :password => 'password',
          :password_confirmation => 'password',
        }
      }

      assert_select 'p.help-inline', 'OpenShift does not allow creating accounts with email addresses from anonymous mail services due to security concerns. Please use a different email address.'
    end
  end
end
