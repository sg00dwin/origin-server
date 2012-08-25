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

  def get_post_form
    {:login => 'tester@example.com', :password => 'pw1234', :password_confirmation => 'pw1234'}
  end
end
