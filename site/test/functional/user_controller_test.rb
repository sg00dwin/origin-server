require 'test_helper'

class UserControllerTest < ActionController::TestCase
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

  test "should get success on post" do
    post(:create, {:web_user => get_post_form})
    assert_equal 0, assigns(:user).errors.length
    assert_response :success
  end

  test "should ignore captcha non-integrated environment" do
    Rails.configuration.expects(:integrated).returns(false)
    @controller.expects(:verify_recaptcha).never
    post(:create, {:web_user => {}})
    assert_response :success
  end

  test "should ignore captcha secret supplied" do
    Rails.configuration.expects(:integrated).returns(true)
    Rails.configuration.expects(:captcha_secret).returns('123')
    @controller.expects(:verify_recaptcha).never
    post(:create, {:web_user => {}, :captcha_secret => '123'})
    assert_response :success
  end

  test "should have captcha checked" do
    Rails.configuration.expects(:integrated).returns(true)
    @controller.expects(:verify_recaptcha).returns(true)
    post(:create, {:web_user => {}})
    assert_response :success
  end

	test "should have captcha check fail" do
		Rails.configuration.expects(:integrated).returns(true)
		@controller.expects(:verify_recaptcha).returns(false)
		post(:create, {:web_user => {}})

		assert_equal "Captcha text didn't match", assigns(:user).errors[:captcha].to_s
	end

	test "should get success on post and choosing Flex" do
		post(:create, {:web_user => get_post_form.merge({:cloud_access_choice => CloudAccess::FLEX})})

		assert_equal 'flex', assigns(:product)
		assert_response :success
	end

	test "should get success on post and choosing Express" do
		post(:create, {:web_user => get_post_form.merge({:cloud_access_choice => CloudAccess::EXPRESS})})

		assert_equal 'express', assigns(:product)
		assert_response :success
	end

	test "should create new flex user" do
		get(:new_flex)

		assert assigns(:user)
		assert_equal assigns(:user).cloud_access_choice, CloudAccess::FLEX
		assert_equal assigns(:product), 'flex'
		assert_response :success
	end

	test "should create new express user" do
		get(:new_express)

		assert assigns(:user)
		assert_equal assigns(:user).cloud_access_choice, CloudAccess::EXPRESS
		assert_equal assigns(:product), 'express'
		assert_response :success
	end


  def get_post_form
    {:email_address => 'tester@example.com', :password => 'pw1234', :password_confirmation => 'pw1234'}
  end
end
