require 'test_helper'

class TermsControllerTest < ActionController::TestCase
  test "show accept terms unauthenticated" do
    get :new
    assert_redirected_to login_path
    assert_equal new_terms_path, session[:workflow]
  end

  test "show accept terms" do
    setup_session
    get :new
    assert_response :success
  end

  test "accept terms unauthenticated" do
    post :create
    assert_redirected_to login_path
    assert_equal new_terms_path, session[:workflow]
  end

  test "terms not accepted" do
    setup_session
    post :create
    assert_equal 1, assigns(:term).errors.length
    assert_response :success
  end

  test "accept terms empty params" do
    setup_session
    post(:create, {:term => {}})
    assert_equal 1, assigns(:term).errors.length
    assert_response :success
  end

  test "accept terms with streamline errors" do
    @controller.expects(:check_credentials)

    # Override the returned user with one that has errors
    # to simulate a failure
    user = WebUser.new
    user.site_terms = []
    user.errors.add(:base, "test")
    user.expects(:establish_terms).once
    user.expects(:accept_terms).never
    @controller.expects(:session_user).returns(user)

    post(:create,
         {"term" => {"terms_accepted"=>"on", "accepted_terms_list"=>"[1,1010]"}},
         {:user => user}
        )
    assert_equal 1, assigns(:term).errors.length
    assert_response :success
  end

  test "accept terms but already accepted" do
    setup_session
    user = session[:user]
    user.expects(:establish_terms).once
    user.expects(:accept_site_terms).never
    post(:create, {"term" => {"terms_accepted"=>"on", "accepted_terms_list"=>"[1]"}})
    assert_equal 0, assigns(:term).errors.length
    assert_redirected_to root_path
  end

  test "accept terms successfully" do
    setup_session
    user = session[:user]
    user.site_terms = [{'termId' => '1', 'termUrl' => 'localhost'}]
    user.expects(:establish_terms).once
    post(:create, {"term" => {"terms_accepted"=>"on", "accepted_terms_list"=>"[1]"}})
    assert_equal 0, assigns(:term).errors.length
    assert_redirected_to root_path
  end

  test "accept terms successfully with workflow" do
    setup_session
    session[:workflow] = login_path
    user = session[:user]
    user.site_terms = [{'termId' => '1', 'termUrl' => 'localhost'}]
    user.expects(:establish_terms).once
    post(:create, {"term" => {"terms_accepted"=>"on", "accepted_terms_list"=>"[1]"}})
    assert_equal 0, assigns(:term).errors.length
    assert_redirected_to login_path
  end

  test "show site terms" do
    get :site_terms
    assert_response :success
  end

  test "show service agreement" do
    get :services_agreement
    assert_response :success
  end
end
