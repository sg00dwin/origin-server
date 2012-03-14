require 'test_helper'

class LoginControllerTest < ActionController::TestCase

  def with_custom_config(options={}, integrated=Rails.configuration.integrated, &block)
    rconf = Rails.configuration
    streamline = rconf.streamline
    old_integrated = rconf.integrated
    old_streamline = streamline.clone

    rconf.integrated = integrated
    streamline.merge!(options)

    yield

    rconf.integrated = old_integrated
    rconf.streamline = old_streamline
  end

  def integrated_user
    {:login => 'ccoleman@redhat.com', :password => 'aoeuaoeu'}
  end

  def internal_user
    {:login => 'test', :password => 'password'}
  end

  test "should get index" do
    get :show
    #assert assigns(:redirectUrl)
    #assert assigns(:errorUrl)
    assert_response :success
    assert_template :show
  end

  test "login" do
    post :create, internal_user
    assert assigns(:user)
    assert_equal assigns(:user).ticket, cookies['rh_sso']
    assert_equal 'true', cookies['prev_login']
    assert_not_nil session[:ticket_verified]
    assert_redirected_to console_path
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
    post :create, internal_user.merge(:redirectUrl => new_application_path)
    assert_redirected_to new_application_path
  end

  test "should ignore external referrer" do
    @request.env['HTTP_REFERER'] = 'http://external.com/test'
    get :show
    assert_nil assigns(:redirectUrl)
  end

  test "should not allow internal relative referrer" do
    @request.env['HTTP_REFERER'] = new_application_path
    get :show
    assert_nil assigns(:redirectUrl)
  end

  test "should not allow internal absolute referrer" do
    @request.env['HTTP_REFERER'] = new_application_url
    get :show
    assert_nil assigns(:redirectUrl)
  end

  test 'cookie domain can be external' do
    with_custom_config({:cookie_domain => '.test.com'}, false) do
      opts = @controller.domain_cookie_opts({})
      assert_equal '.test.com', opts[:domain]
    end
  end

  test 'cookie domain can be loosely defined' do
    with_custom_config({:cookie_domain => 'test.com'}, false) do
      opts = @controller.domain_cookie_opts({})
      assert_equal '.test.com', opts[:domain]
    end
  end

  test 'cookie domain can depend on request' do
    @request.host = 'a.test.domain.com'
    with_custom_config({:cookie_domain => :current}, false) do
      opts = @controller.domain_cookie_opts({})
      assert_equal '.a.test.domain.com', opts[:domain]
    end
  end

  test 'integrated default domain_cookie_opts' do
    with_custom_config({}, false) do
      opts = @controller.domain_cookie_opts({})
      assert_equal '/', opts[:path]
      assert_equal true, opts[:secure]
      assert_equal '.redhat.com', opts[:domain]
      assert_nil opts[:value]
    end
  end

  test 'default domain_cookie_opts are overridden' do
    opts = @controller.domain_cookie_opts({
      :path => '/foo',
      :secure => false,
      :value => 'bar'
    })
    assert_equal '/foo', opts[:path]
    assert_equal false, opts[:secure]
    assert_equal 'bar', opts[:value]
  end

  test 'domain_cookie_opts with implied hash' do
    opts = @controller.domain_cookie_opts(:value => 'foobar')
    assert_equal 'foobar', opts[:value]
  end
end
