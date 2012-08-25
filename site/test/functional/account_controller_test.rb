require File.expand_path('../../test_helper', __FILE__)

class AccountControllerTest < ActionController::TestCase

  test "should get new unauthorized" do
    get :new
    assert_response :success
  end

  test "should get too short password error" do
    form = get_post_form
    form[:password]='short'
    post(:create, {:web_user => form})
    assert assigns(:user)
    assert assigns(:user).errors[:password].length > 0
    assert_response :success
  end

  test "should get password must match error" do
    form = get_post_form
    form[:password]='doesntmatch'
    post(:create, {:web_user => form})
    assert assigns(:user)
    assert assigns(:user).errors[:password].length > 0
    assert_response :success
  end

  test "should get invalid email address" do
    form = get_post_form
    form[:email_address]='notreallyanemail'
    post(:create, {:web_user => form})
    assert assigns(:user)
    assert assigns(:user).errors[:email_address].length > 0
    assert_response :success
  end

  test "should get invalid email address domain" do
    form = get_post_form
    form[:email_address]='test@example.ir'
    post(:create, {:web_user => form})
    assert assigns(:user)
    assert assigns(:user).errors[:email_address].length > 0
    assert_response :success
  end

  test "should get missing fields" do
    post(:create, {:web_user => {}})
    assert assigns(:user)
    assert assigns(:user).errors[:email_address].length > 0
    assert assigns(:user).errors[:password].length > 0
    assert_response :success
  end

  test "should get redirect on post" do
    post(:create, {:web_user => get_post_form})
    assert assigns(:user).errors.empty?
    assert_redirected_to complete_account_path
  end

  test "should get promo code redirect on post" do
    WebUser::Mock.any_instance.expects(:register).with(anything, 'a_code').returns(true)
    post(:create, {:web_user => get_post_form.merge!(:promo_code => 'a_code')})
    assert assigns(:user).errors.empty?
    assert_redirected_to complete_account_path(:promo_code => 'a_code')
  end

  test "should ignore captcha non-integrated environment" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('123')
    Rails.configuration.expects(:integrated).at_least_once.returns(false)
    @controller.expects(:verify_recaptcha).once
    post(:create, {:web_user => {}})
    assert_response :success
  end

  test "should render dashboard" do
    with_unique_user
    get :show
    assert_response :success
    assert assigns(:user).email_address.present?
    assert assigns(:identities).present?
    assert assigns(:domain).nil?

    if Rails.configuration.aria_enabled
      assert assigns(:plan).present?, assigns(:user).inspect
      assert_select 'a', 'Upgrade now!'
      assert_select 'p', /FreeShift/, response.inspect
    else
      assert assigns(:plan).nil?
      assert_select 'a', /Learn more about upcoming/
      assert_select 'p', /FreeShift/, response.inspect
    end
  end

  test "should render captcha" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('123')
    get :new
    assert_response :success
    assert_select "#recaptcha_widget"
  end

  test "should render page without captcha when secret is present" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('123')
    get :new, {:web_user => {}, :captcha_secret => '123'}
    assert_response :success
    assert css_select("#recaptcha_widget").empty?
  end

  test "should render page without captcha when secret is nil" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns(nil)
    get :new, {:web_user => {}}
    assert_response :success
    assert css_select("#recaptcha_widget").empty?
  end

  test "should ignore captcha when secret is correct" do
    Rails.configuration.expects(:integrated).at_least_once.returns(false)
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('123')
    @controller.expects(:verify_recaptcha).never
    post(:create, {:web_user => {}, :captcha_secret => '123'})
    assert_response :success
    assert_template :new
    assert_equal '123', assigns(:captcha_secret)
    assert assigns(:user).errors.present?
  end

  test "should check captcha when secret is incorrect" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('123')
    @controller.expects(:verify_recaptcha)
    post(:create, {:web_user => {}, :captcha_secret => '321'})
    assert_response :success
    assert_template :new
    assert_nil assigns(:captcha_secret)
  end

  test "should check captcha" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('123')
    Rails.configuration.expects(:integrated).at_least_once.returns(false)
    @controller.expects(:verify_recaptcha).returns(true)
    post(:create, {:web_user => {}})
    assert_response :success
  end

	test "should have captcha check fail" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('123')
    Rails.configuration.expects(:integrated).at_least_once.returns(false)
		@controller.expects(:verify_recaptcha).returns(false)
		post(:create, {:web_user => {}})

		assert_equal "Captcha text didn't match", assigns(:user).errors[:captcha].to_s
    assert_nil assigns(:captcha_secret)
	end

  test "should have captcha check succeed when secret is nil" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns(nil)
    Rails.configuration.expects(:integrated).at_least_once.returns(false)
		post(:create, {:web_user => {}})
    assert_response :success
	end

	test "should get success on post and choosing Express" do
		post(:create, {:web_user => get_post_form.merge({:cloud_access_choice => CloudAccess::EXPRESS})})

		assert_equal 'openshift', assigns(:product)
    assert_redirected_to complete_account_path
	end

  test "should register user from external" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('secret')
    post(:create_external, {:json_data => '{"email_address":"tester@example.com","password":"pw1234"}', :captcha_secret => 'secret', :registration_referrer => 'appcelerator'})
    assert_response :success
  end

  test "should fail register external with invalid secret" do
    post(:create_external, {:json_data => '{"email_address":"tester@example.com","password":"pw1234"}', :captcha_secret => 'wrongsecret', :registration_referrer => 'appcelerator'})
    assert_response 401
  end
  
  test "should fail register external with invalid password" do
    post(:create_external, {:json_data => '{"email_address":"tester@example.com","password":"pw"}', :captcha_secret => 'secret', :registration_referrer => 'appcelerator'})
    assert_response 400
  end
  
  test "should fail register external with no registration referrer" do
    post(:create_external, {:json_data => '{"email_address":"tester@example.com","password":"pw1234"}', :captcha_secret => 'secret'})
    assert_response 400
  end

  test "promo code should cause email to be sent and session to be set" do
    email_obj = Object.new
    PromoCodeMailer.expects(:promo_code_email).once.returns(email_obj)
    email_obj.expects(:deliver).once

    form = get_post_form
    form[:promo_code]='promo1'
    post(:create, {:web_user => form})
    assert user = assigns(:user)
    assert "promo1", user.promo_code

    assert_redirected_to complete_account_path(:promo_code => 'promo1')
  end

  def get_post_form
    {:email_address => 'tester@example.com', :password => 'pw1234', :password_confirmation => 'pw1234'}
  end
end
