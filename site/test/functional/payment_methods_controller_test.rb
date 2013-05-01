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

  test "should display payment method errors" do
    with_account_holder
    get :edit, :plan_id => :silver, :payment_method => {:errors => {:base => 'foo', :cvv => 'servercvvmustbenumeric'}}
    assert_response :success
    assert_select ".alert.alert-error", /payment information could not be processed/
    assert_select "#aria_payment_method_cvv_input.error .help-inline", /security code is a three or four digit/
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
        :error_key => 'serveraccountdetails'
      },
      1 => {
        :error_field => 'cc_no',
        :error_key => 'servercardnumnumeric'
      }
    }})
    assert_redirected_to edit_account_payment_method_path({:payment_method => {:errors => {:base => ['serveraccountdetails'], :cc_no => ['servercardnumnumeric']}}})
  end
end
