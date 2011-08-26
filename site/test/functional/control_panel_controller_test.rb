require 'test_helper'

class ControlPanelControllerTest < ActionController::TestCase

  test "should get redirected to login page" do
    get :index
    assert_response :redirect
    assert_redirected_to :controller => "login", :action => "show"
  end

  test "should create a new namespace" do
    setup_session
    get :index

    # Namespace needs to be nil for the rest of the tests to pass
    assert_nil assigns(:userinfo).namespace

    # Ensure that the domain is created 
    assert assigns(:domain)
    assert_instance_of ExpressDomain, assigns(:domain)

    # Make sure the action is to create a new domain
    assert assigns(:action)
    assert_equal 'create', assigns(:action)

    assert_response :success
  end

  test "should edit an existing namespace" do
    setup_session
    ExpressUserinfo.any_instance.stubs('namespace').returns('test.com')

    get :index

    # Ensure that the domain is created 
    assert assigns(:domain)
    assert_instance_of ExpressDomain, assigns(:domain)

    # Make sure the action is to create a new domain
    assert assigns(:action)
    assert_equal 'update', assigns(:action)

    assert_response :success
  end

end
