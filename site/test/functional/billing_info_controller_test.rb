require File.expand_path('../../test_helper', __FILE__)

class BillingInfoControllerTest < ActionController::TestCase
  test "should provide billing info on edit" do
    with_account_holder
    get :edit
    assert_response :success
    assert_not_nil assigns(:billing_info)
  end

  test "update should return to account page if no validation errors" do
    with_account_holder
    aria_billing_info = Aria::BillingInfo.test.attributes
    mock_controller_user(Aria::User).expects(:update_account).returns(true)
    post :update, :aria_billing_info => aria_billing_info
    assert_redirected_to account_path
  end

  test "update should return to edit page if validation errors" do
    with_account_holder
    aria_billing_info = Aria::BillingInfo.test.attributes
    mock_controller_user(Aria::User).expects(:update_account).returns(false)
    post :update, :aria_billing_info => aria_billing_info
    assert_template :edit
  end

  test "should provide account path" do
    assert_equal account_path, @controller.next_path
    assert_equal account_path, @controller.previous_path
  end
end
