require File.expand_path('../../test_helper', __FILE__)

class AccountControllerTest < ActionController::TestCase
  def setup
    @controller.stubs(:skip_captcha?).returns(true)
  end

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

  test "should render dashboard" do
    omit_if_aria_is_unavailable if Rails.configuration.aria_enabled
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

	test "should get success on post and choosing Express" do
		post(:create, {:web_user => get_post_form.merge({:cloud_access_choice => CloudAccess::EXPRESS})})

		assert_equal 'openshift', assigns(:product)
    assert_redirected_to complete_account_path
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
