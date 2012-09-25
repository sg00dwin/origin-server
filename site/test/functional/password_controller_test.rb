require File.expand_path('../../test_helper', __FILE__)

class PasswordControllerTest < ActionController::TestCase
  test "should get new unauthorized" do
    get :new
    assert_response :success
  end

  test "should get too short password error" do
    return unless Rails.configuration.integrated
    setup_user
    form = get_post_form
    form[:password]='short'
    post(:update, {:web_user => form})
    assert assigns(:user)
    assert assigns(:user).errors[:password].length > 0
    assert_response :success
  end

  test "should get password must match error" do
    return unless Rails.configuration.integrated
    setup_user
    form = get_post_form
    form[:password]='doesntmatch'
    post(:update, {:web_user => form})
    assert assigns(:user)
    assert assigns(:user).errors[:password].length > 0
    assert_response :success
  end

  test "should get missing fields" do
    post(:create, {:web_user => {}})
    assert assigns(:user)
    assert assigns(:user).errors[:login].length > 0
    assert assigns(:user).errors[:password].length == 0 # password reset only requires e-mail
    assert_response :success
  end
  
  test "should redirect on success" do
    post(:create, :web_user => get_post_form)
    assert assigns(:user)
    assert assigns(:user).errors.empty?
    assert_redirected_to :action => 'success'
    assert_template
  end

  test 'reset should succeed' do
    WebUser::Mock.any_instance.expects(:complete_reset_password).with('foo').returns(true)
    get :reset, :token => 'foo', :email => 'test@test.com'
    assert_response :success
    assert_template :reset
  end

  test 'reset should display generic error' do
    WebUser::Mock.any_instance.expects(:complete_reset_password).with('foo').returns(false)
    get :reset, :token => 'foo', :email => 'test@test.com'
    assert_response :success
    assert_template :reset_error
  end

  test 'reset should handle missing email' do
    get :reset, :token => 'foo'
    assert_response :success
    assert_template :reset_error
  end

  test 'reset should handle missing token' do
    get :reset, :email => 'foo@foo.com'
    assert_response :success
    assert_template :reset_error
  end

  test 'reset should handle expired token' do
    get :reset, :token => 'expired', :email => 'test@test.com'
    assert_response :success
    assert_template :reset_expired
  end

  def get_post_form
    {:login => 'tester@example.com', :password => 'pw1234', :password_confirmation => 'pw1234'}
  end
end
