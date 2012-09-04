require File.expand_path('../../test_helper', __FILE__)

class LoginControllerTest < ActionController::TestCase

  def simple_user
    {:rhlogin => 'test@example.com', :password => 'password'}
  end

  def full_user
    {:rhlogin => 'test', :password => 'password'}
  end

  test "should get form" do
    get :show
    #assert assigns(:redirectUrl)
    #assert assigns(:errorUrl)
    assert_response :success
    assert_template :show
    assert_select('form input[name*=rhlogin]') do |elements|
      assert_equal 'web_user[rhlogin]', elements[0]['name']
    end
  end

  test "login as simple user" do
    post :create, simple_user
    assert user = assigns(:user)
    assert !user.roles.empty?
    assert_redirected_to console_path
    assert_equal true, cookies['prev_login']
    assert_not_nil session[:ticket_verified]
    assert_equal :simple, session[:streamline_type]
    #assert_equal assigns(:user).ticket, cookies['rh_sso'] #FIXME: broken, can't get cookie
  end

  test "login as full user" do
    post :create, full_user
    assert user = assigns(:user)
    assert !user.roles.empty?
    assert_redirected_to console_path
    assert_equal true, cookies['prev_login']
    assert_not_nil session[:ticket_verified]
    assert_equal :full, session[:streamline_type]
    #assert_equal assigns(:user).ticket, cookies['rh_sso'] #FIXME: broken, can't get cookie
  end

  test "login should fail" do
    post :create, {:login => ''}
    assert assigns(:user)
    assert assigns(:user).errors.present?
    assert_nil cookies['prev_login']
    assert_nil cookies['rh_sso']
    assert_response :success
    assert_template :show
  end

  test "should preserve redirectUrl on failure" do
    post :create, {:login => '', :redirectUrl => new_application_path}
    assert assigns(:user)
    assert assigns(:user).errors.present?
    assert_equal new_application_path, assigns(:redirectUrl)
    assert_nil cookies['prev_login']
    assert_nil cookies['rh_sso']
    assert_response :success
    assert_template :show
  end

  test "should allow redirectUrl param" do
    post :create, simple_user.merge(:redirectUrl => new_application_path)
    assert_redirected_to new_application_path
  end

  test "should not allow external redirectUrl param" do
    post :create, simple_user.merge(:redirectUrl => 'http://www.google.com/a_test_path')
    assert_redirected_to '/a_test_path'
  end

  test "should allow then param" do
    post :create, simple_user.merge(:then => new_application_path)
    assert_redirected_to new_application_path
  end


  test "should ignore external referrer" do
    @request.env['HTTP_REFERER'] = 'http://external.com/test'
    get :show
    assert_equal 'http://external.com/test', assigns(:redirectUrl)
  end

  test "should allow internal relative referrer" do
    @request.env['HTTP_REFERER'] = new_application_path
    get :show
    assert_equal new_application_path, assigns(:redirectUrl)
  end

  test "should allow internal absolute referrer" do
    @request.env['HTTP_REFERER'] = new_application_url
    get :show
    assert_equal new_application_url, assigns(:redirectUrl)
  end

  test "should send certain urls to default" do
    [login_path, new_account_path, reset_account_password_path, complete_account_path].each do |path|
      @request.env['HTTP_REFERER'] = path
      get :show
      assert_nil assigns(:redirectUrl)
    end
  end
end
