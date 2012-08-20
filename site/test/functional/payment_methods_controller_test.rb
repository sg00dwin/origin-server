require File.expand_path('../../test_helper', __FILE__)

class PaymentMethodsControllerTest < ActionController::TestCase
  test "should display payment method errors" do
    with_account_holder
    get :edit, :plan_id => :megashift, :payment_method => {:errors => {:base => 'foo', :cvv => 'servercvvmustbenumeric'}}
    assert_response :success
    assert_select ".alert.alert-error", /payment information could not be processed/
    assert_select "#aria_payment_method_cvv_input.error .help-inline", /security code is a three or four digit/
  end

  test "should redirect when aria reports success" do
    with_account_holder
    mock_controller_user(Aria::User).expects(:has_valid_payment_method?).returns(true)
    get :direct_update, :plan_id => :megashift
    assert_redirected_to account_path
  end

  test "should redirect when aria reports an error" do
    with_account_holder
    mock_controller_user(Aria::User).expects(:has_valid_payment_method?).returns(true)
    get(:direct_update, {:plan_id => :megashift, :error_messages => {
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
