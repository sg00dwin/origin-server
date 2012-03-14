require 'test_helper'

class LoginControllerTest < ActionController::TestCase
  test "should get index" do
    get :show
    #assert assigns(:redirectUrl)
    #assert assigns(:errorUrl)
    assert_response :success
    assert_template :show
  end

  test "should get error" do
    #Uncomment during refactoring
    #post :create, {:login => ''}
    #assert assigns(:user)
    #assert !assigns(:user).errors.empty?
    #assert_response :success
    #assert_template :show
    #assert_equal 'simple', @response.layout
  end

  test 'default domain_cookie_opts' do
    old_integrated = Rails.configuration.integrated
    Rails.configuration.integrated = false

    opts = @controller.domain_cookie_opts({})
    assert_equal '/', opts[:path]
    assert_equal true, opts[:secure]
    assert_nil opts[:value]

    # reset to original state
    Rails.configuration.integrated = old_integrated
  end

  test 'integrated default domain_cookie_opts' do
    old_integrated = Rails.configuration.integrated
    Rails.configuration.integrated = true

    opts = @controller.domain_cookie_opts({})
    assert_equal '/', opts[:path]
    assert_equal true, opts[:secure]
    assert_equal '.redhat.com', opts[:domain]
    assert_nil opts[:value]

    # reset to original state
    Rails.configuration.integrated = old_integrated
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
