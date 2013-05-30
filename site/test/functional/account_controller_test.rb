require File.expand_path('../../test_helper', __FILE__)

class AccountControllerTest < ActionController::TestCase
  def setup
    @controller.stubs(:skip_captcha?).returns(true)
  end

  def stub_aria_checks; end

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

  if Rails.configuration.aria_enabled
    test "should render dashboard with aria" do
      omit_if_aria_is_unavailable
      with_unique_user
      get :show
      assert_response :success
      assert_template :dashboard_free
      assert assigns(:user)

      assert assigns(:plan).nil?, assigns(:user).inspect
      assert_select 'a', 'Upgrade Now'
      assert_select 'h1', /Free/, response.inspect
    end

    { :dunning => 'Your account is overdue on payment',
      :suspended => 'Your account has been flagged for suspension',
      :terminated => 'Your account has been flagged for termination',
    }.each_pair do |status,message|
      test "should render a warning if the Aria account is in #{status} status" do
        omit_if_aria_is_unavailable
        with_unique_user
        Aria::UserContext.any_instance.expects(:account_status).at_least_once.returns(status)
        Aria::UserContext.any_instance.expects(:acct_no).at_least_once.returns(1)
        Aria::UserContext.any_instance.expects(:test_user?).at_least_once.returns(true)
        Aria::UserContext.any_instance.expects(:next_bill).at_least_once.returns(false)
        Aria::UserContext.any_instance.expects(:last_bill).at_least_once.returns(false)
        Aria::UserContext.any_instance.expects(:default_plan_pending?).at_least_once.returns(false)
        Aria::UserContext.any_instance.expects(:has_valid_payment_method?).at_least_once.returns(true)
        get :show
        assert_response :success
        assert_template :show
        assert_equal status, assigns(:account_status)
        assert_select (status == :terminated ? '.alert-error' : '.alert-warning'), :text => /#{message}/
      end
    end

    test "should suppress the plan upgrade button when account is in termination status" do
        omit_if_aria_is_unavailable
        with_unique_user
        Aria::UserContext.any_instance.expects(:account_status).at_least_once.returns(:terminated)
        Aria::UserContext.any_instance.expects(:acct_no).at_least_once.returns(1)
        Aria::UserContext.any_instance.expects(:test_user?).at_least_once.returns(true)
        Aria::UserContext.any_instance.expects(:next_bill).at_least_once.returns(false)
        Aria::UserContext.any_instance.expects(:last_bill).at_least_once.returns(nil)
        Aria::UserContext.any_instance.expects(:default_plan_pending?).at_least_once.returns(false)
        Aria::UserContext.any_instance.expects(:has_valid_payment_method?).at_least_once.returns(true)
        get :show
        assert_response :success
        assert_template :show
        assert_equal :terminated, assigns(:account_status)
        assert_select 'a', :text => 'Upgrade Now', :count => 0
    end

    test "should render dashboard with no next bill" do
      omit_if_aria_is_unavailable
      with_account_holder
      Aria::UserContext.any_instance.expects(:next_bill).returns(false)
      Aria::UserContext.any_instance.expects(:last_bill).returns(nil)
      get :show
      assert_response :success
      assert_template :show
      assert assigns(:user)
      assert assigns(:plan)
      assert_select 'a', 'Upgrade Now'
      assert_select 'p', /not currently subscribed/
    end

    test "should show dashboard without last bill" do
      omit_if_aria_is_unavailable
      with_account_holder
      Aria::UserContext.any_instance.expects(:next_bill).returns(false)
      Aria::UserContext.any_instance.expects(:last_bill).returns(nil)
      get :show
      assert_response :success
      assert_template :show
      assert assigns(:user)
      assert assigns(:plan)
      assert_select 'h2:content(?)', /previous bill/, :count => 0
      assert_select 'a:content(?)', 'View billing history', :count => 0
    end

    test "should show dashboard with unpaid last bill" do
      omit_if_aria_is_unavailable
      with_account_holder
      Aria::UserContext.any_instance.expects(:next_bill).returns(false)
      Aria::UserContext.any_instance.expects(:last_bill).returns(Aria::Bill.new(
        :due_date => '2010-02-01'.to_datetime,
        :paid_date => nil,
        :forwarded_balance => 100
      ))
      get :show
      assert_response :success
      assert_template :show
      assert assigns(:user)
      assert assigns(:plan)
      assert_select 'h2:content(?)', /previous bill .* due/
      assert_select 'a:content(?)', 'View billing history'
    end

    test "should show dashboard with paid last bill" do
      omit_if_aria_is_unavailable
      with_account_holder
      Aria::UserContext.any_instance.expects(:next_bill).returns(false)
      Aria::UserContext.any_instance.expects(:last_bill).returns(Aria::Bill.new(
        :due_date => '2010-02-01'.to_datetime,
        :paid_date => '2010-02-01'.to_datetime,
        :forwarded_balance => 100
      ))
      get :show
      assert_response :success
      assert_template :show
      assert assigns(:user)
      assert assigns(:plan)
      assert_select 'h2:content(?)', /previous bill .* paid/
      assert_select 'a:content(?)', 'View billing history'
    end

    test "should show account dashboard" do
      omit_if_aria_is_unavailable
      with_account_holder
      get :show
      assert_response :success
      assert_template :show
      assert assigns(:user)
      assert assigns(:plan)

      assert assigns(:plan), assigns(:user).inspect
      assert_select 'h2:content(?)', 'Next Bill'
    end
  end

  test "should render dashboard without aria" do
    with_config(:aria_enabled, false) do
      with_unique_user
      get :show
      assert_response :success
      assert_template :dashboard_free
      assert assigns(:user)

      assert assigns(:plan).nil?
      assert_select 'a', /Get more help and information/
      assert_select 'h1', /Free/, response.inspect
    end
  end

  test "should get success on post and choosing Express" do
    post(:create, {:web_user => get_post_form})

    assert_equal 'openshift', assigns(:product)
    assert_redirected_to complete_account_path
  end

  test "promo code failure should log error" do
    e = StandardError.new('Bad Email')
    PromoCodeMailer.expects(:promo_code_email).once.raises(e)
    AccountController.any_instance.expects(:log_error).with(e, 'Unable to send promo code')

    post :create, :web_user => get_post_form.merge({:promo_code => 'test'})

    assert_equal 'openshift', assigns(:product)
    assert_redirected_to complete_account_path :promo_code => :test
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

  test 'should send support contact mail' do
    skip 'until support emails are re-enabled'

    with_unique_user
    email_obj = Object.new
    AccountSupportContactMailer.expects(:contact_email).once.returns(email_obj)
    email_obj.expects(:deliver).once

    post(:contact_support,
      {:support_contact => {
        :from => 'test@example.com',
        :to => Rails.configuration.acct_help_mail_to,
        :subject => 'test',
        :body => 'nothing'}})
    assert contact = assigns(:contact)
    assert_redirected_to({:action => 'help'})
  end

  def get_post_form
    {:email_address => 'tester@example.com', :password => 'pw1234', :password_confirmation => 'pw1234'}
  end
end
