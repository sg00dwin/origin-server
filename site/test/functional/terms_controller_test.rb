require File.expand_path('../../test_helper', __FILE__)

class TermsControllerTest < ActionController::TestCase
  test "show accept terms unauthenticated" do
    get :new
    assert_redirected_to login_path
  end

  test "redirect to legal site terms when none to accept" do
    setup_user
    get :new
    assert_redirected_to legal_site_terms_path
  end

  test "show terms" do
    setup_user
    user = WebUser.new
    user.send('terms=', ['1'])
    @controller.expects(:session_user).at_least_once.returns(user)
    get :new
    assert_response :success
  end

  test "accept terms unauthenticated" do
    post :create
    assert_redirected_to login_path
  end

  test "accept terms with streamline errors" do
    # Override the returned user with one that has errors
    # to simulate a failure
    user = WebUser.new
    user.send('terms=', ['1'])
    user.errors.add(:base, "test")
    @controller.expects(:session_user).at_least_once.returns(user)

    post(:create, {}, {:user => user})
    assert_equal 1, assigns(:term).errors.length
    assert_response :success
  end

  test "accept terms but already accepted" do
    setup_user
    user = @controller.session_user
    user.send('terms=', [])
    user.expects(:accept_terms).never    
    post :create
    assert_equal 0, assigns(:term).errors.length
    assert_redirected_to console_path
  end

  test "accept terms successfully" do
    setup_user
    user = @controller.session_user
    user.send('terms=', [{'termId' => '1', 'termUrl' => 'localhost'}])
    user.expects(:accept_terms).once
    post :create
    assert_equal 0, assigns(:term).errors.length
    assert_redirected_to console_path
  end

  test "accept terms successfully with workflow" do
    setup_user
    @controller.terms_redirect = account_path
    user = @controller.session_user
    user.send('terms=', [{'termId' => '1', 'termUrl' => 'localhost'}])
    user.expects(:accept_terms).once
    post :create
    assert_equal 0, assigns(:term).errors.length
    assert_redirected_to account_path
  end

  test "accept terms successfully with external workflow" do
    setup_user
    url = 'http://external.url/to-something' 
    @controller.terms_redirect = url
    user = @controller.session_user
    user.send('terms=', [{'termId' => '1', 'termUrl' => 'localhost'}])
    user.expects(:accept_terms).once
    post :create
    assert_equal 0, assigns(:term).errors.length
    assert_redirected_to url
  end

  test "show acceptance terms" do
    setup_user
    user = @controller.session_user
    user.send('terms=', [{'termId' => '1', 'termUrl' => 'localhost', 'termTitle' => 'title'}])
    get :acceptance_terms
    assert_equal 0, assigns(:term).errors.length
    assert_response :success
  end

  test "verify auto-access doesn't fire before accepting terms" do
    setup_user

    # Remove the key that denotes terms acceptance
    session.delete(:login)

    # Make sure request access is not called in this scenario
    @controller.expects(:request_access).never

    get :new
  end
end
