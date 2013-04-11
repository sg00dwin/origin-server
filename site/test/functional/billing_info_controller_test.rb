require File.expand_path('../../test_helper', __FILE__)

class BillingInfoControllerTest < ActionController::TestCase
  test "should provide billing info on edit" do
    omit_if_aria_is_unavailable
    with_account_holder
    get :edit
    assert_response :success
    assert_not_nil assigns(:billing_info)
  end

  test "update should return to account page if no validation errors" do
    omit_if_aria_is_unavailable
    with_account_holder
    aria_billing_info = Aria::BillingInfo.test.attributes
    Aria::UserContext.any_instance.expects(:update_account).returns(true)
    post :update, :aria_billing_info => { :aria_billing_info => aria_billing_info }
    assert_redirected_to account_path
  end

  test "should prevent changing currency once set" do
    omit_if_aria_is_unavailable
    with_account_holder
    get :edit
    assert_response :success
    assert_not_nil assigns(:billing_info)
    aria_billing_info = assigns(:billing_info).attributes
    aria_billing_info['currency_cd'] = aria_billing_info['currency_cd'] == 'usd' ? 'eur' : 'usd'
    post :update, :aria_billing_info => { :aria_billing_info => aria_billing_info }
    assert assigns(:aria_user)
    assert assigns(:billing_info).errors[:base].length > 0
    assert_template :edit
  end

  test "should update user account" do
    omit_if_aria_is_unavailable
    acct_info = {
      'CA' => {
        'zip' => 'K1A0B1',
        'city' => 'Ottawa',
        'region' => 'ON',
        'country' => 'CA',
      },
      'US' => {
        'zip' => '77001',
        'city' => 'Houston',
        'region' => 'TX',
        'country' => 'US',
      },
    }
    assert user = with_account_holder
    assert initial_billing_info = user.billing_info.attributes
    target_country = (initial_billing_info['country'] == 'US') ? 'CA' : 'US'
    acct_info[target_country].each_pair do |k,v|
      initial_billing_info[k] = v
    end
    post :update, :aria_billing_info => { :aria_billing_info => initial_billing_info }
    assert_redirected_to account_path
    acct_info[target_country].each_pair do |k,v|
      assert user.billing_info.attributes[k] == v
    end
  end

  test "update should return to edit page if validation errors" do
    omit_if_aria_is_unavailable
    with_account_holder
    aria_billing_info = Aria::BillingInfo.test.attributes
    Aria::UserContext.any_instance.expects(:update_account).returns(false)
    post :update, :aria_billing_info => { :aria_billing_info => aria_billing_info }
    assert_template :edit
  end

  test "update should return to edit page if length validation errors" do
    omit_if_aria_is_unavailable
    with_account_holder
    aria_billing_info = Aria::BillingInfo.test.attributes
    aria_billing_info['middle_initial'] = 'ABC'
    Aria.expects(:update_acct_complete).never()
    post :update, :aria_billing_info => { :aria_billing_info => aria_billing_info }
    assert assigns(:billing_info)
    assert assigns(:billing_info).errors[:middle_initial].length > 0
    assert_template :edit
  end

  test "should provide account path" do
    assert_equal account_path, @controller.next_path
    assert_equal account_path, @controller.previous_path
  end
end
