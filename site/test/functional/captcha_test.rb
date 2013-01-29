require File.expand_path('../../test_helper', __FILE__)

class CaptchaTest < ActionController::TestCase
  def setup
    @controller = AccountController.new
  end

  test "should check captcha when secret is incorrect" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('123')
    @controller.expects(:valid?).once
    post(:create, {:web_user => {}, :captcha_secret => '321'})
    assert_response :success
    assert_template :new
    assert_nil assigns(:captcha_secret)
  end

  test "should ignore captcha when secret is correct" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('123')
    @controller.expects(:valid?).never
    post(:create, {:web_user => {}, :captcha_secret => '123'})
    assert_response :success
    assert_template :new
    assert_equal '123', assigns(:captcha_secret)
    assert assigns(:user).errors.present?
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

  test "should check captcha" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('123')
    @controller.expects(:valid?).returns(true)
    post(:create, {:web_user => {}})
    assert_response :success
  end

	test "should have captcha check fail" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('123')
		@controller.expects(:valid?).returns(false)
		post(:create, {:web_user => {}})

		assert_equal ["Captcha text didn't match"], Array(assigns(:user).errors[:captcha])
    assert_nil assigns(:captcha_secret)
	end

  test "should have captcha check succeed when secret is nil" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns(nil)
		post(:create, {:web_user => {}})
    assert_response :success
	end

  test "should register user from external" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('secret')
    post(:create_external, {:json_data => '{"email_address":"tester@example.com","password":"pw1234"}', :captcha_secret => 'secret', :registration_referrer => 'appcelerator'})
    assert_response :success
  end

  test "should fail register external with invalid secret" do
    Rails.configuration.expects(:captcha_secret).at_least_once.returns('secret')
    post(:create_external, {:json_data => '{"email_address":"tester@example.com","password":"pw1234"}', :captcha_secret => 'wrongsecret', :registration_referrer => 'appcelerator'})
    assert_response 401
  end
end
