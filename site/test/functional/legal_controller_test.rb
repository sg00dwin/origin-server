require 'test_helper'

class LegalControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

  test "show site terms" do
    get :site_terms
    assert_response :success
  end

  test "show services agreement" do
    get :services_agreement
    assert_response :success
  end
end
