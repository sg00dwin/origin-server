require File.expand_path('../../test_helper', __FILE__)

class PaymentMethodsControllerTest < ActionController::TestCase
  with_aria

  test "should display payment method" do
    with_account_holder
    get :edit, :plan_id => :silver
    assert_response :success
    assert_select ".alert.alert-error", 0
    assert_select "#aria_payment_method_cvv_input.error .help-inline", 0
  end

  test "should display payment method errors without error code" do
    with_account_holder
    get :edit, :plan_id => :silver, :payment_method => {:errors => {:base => 'foo', :cvv => 'servercvvmustbenumeric'}}
    assert_response :success
    assert_select ".alert.alert-error", /payment information could not be processed/
    assert_select "#aria_payment_method_cvv_input.error .help-inline", /security code is a three or four digit/
  end

  test "should display payment method errors with error code" do
    with_account_holder
    get :edit, :plan_id => :silver, :payment_method => {:errors => {:base => 'foo,123', :cvv => 'servercvvmustbenumeric'}}
    assert_response :success
    assert_select ".alert.alert-error", /payment information could not be processed.*#123/
    assert_select "#aria_payment_method_cvv_input.error .help-inline", /security code is a three or four digit/
  end

  test "should display warning for missing billing info" do
    with_account_holder
    Aria::UserContext.any_instance.expects(:billing_info).returns(nil)
    get :edit, :plan_id => :silver
    assert_response :success
    assert_select ".alert.alert-warning", /does not have a billing address/
  end

  test "should display warning for invalid billing info" do
    with_account_holder
    Aria::UserContext.any_instance.expects(:billing_info).returns(Aria::BillingInfo.new)
    get :edit, :plan_id => :silver
    assert_response :success
    assert_select ".alert.alert-warning", /billing address may be invalid/
  end

  test "should display correctly for an existing payment method" do
    with_account_holder
    Aria::UserContext.any_instance.expects(:payment_method).returns(Aria::PaymentMethod.new({}, true))
    get :edit, :plan_id => :silver
    assert_response :success
  end

  test "should redirect when aria reports success" do
    with_account_holder
    Aria::UserContext.any_instance.expects(:has_valid_payment_method?).returns(true)
    get :direct_update, :plan_id => :silver
    assert_redirected_to account_path
  end

  test "should redirect when aria reports an error" do
    with_account_holder
    Aria::UserContext.any_instance.expects(:has_valid_payment_method?).returns(true)
    get(:direct_update, {:plan_id => :silver, :error_messages => {
      0 => {
        :error_field => 'server_error',
        :error_key => 'serveraccountdetails',
        :error_code => '123'
      },
      1 => {
        :error_field => 'cc_no',
        :error_key => 'servercardnumnumeric',
        :error_code => '234'
      }
    }})
    assert_redirected_to edit_account_payment_method_path({:payment_method => {:errors => {:base => ['serveraccountdetails,123'], :cc_no => ['servercardnumnumeric']}}})
  end
end
