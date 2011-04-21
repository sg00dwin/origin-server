require 'test_helper'

class TermsControllerTest < ActionController::TestCase
  test "show accept terms unauthenticated" do
    get :new
    assert_redirected_to login_path
    assert_equal new_terms_path, session[:workflow]
  end

  test "show accept terms" do
    get(:new, {}, {:user => WebUser.new})
    assert_response :success
  end

  test "accept terms unauthenticated" do
    post :create
    assert_redirected_to login_path
    assert_equal new_terms_path, session[:workflow]
  end

  test "terms not accepted" do
    post(:create, {}, {:user => WebUser.new})
    assert_equal 1, assigns(:term).errors.length
    assert_response :success
  end

  test "accept terms empty params" do
    post(:create, {:term => {}}, {:user => WebUser.new})
    assert_equal 1, assigns(:term).errors.length
    assert_response :success
  end

#  test "accept terms successfully" do
#    post(:create, {:term => {}}, {:user => WebUser.new})
#    assert_equal 0, assigns(:term).errors.length
#    assert_response :success
#  end

  test "show site terms" do
    get :site_terms
    assert_response :success
  end

  test "show service agreement" do
    get :services_agreement
    assert_response :success
  end
end
