require File.expand_path('../../test_helper', __FILE__)

class LogoutControllerTest < ActionController::TestCase
  test "should get index" do
    get :show
    assert_redirected_to root_path
  end

  test "should clear session and cookies" do
    # Create the test rh_sso cookie
    @request.cookies['rh_sso'] = CGI::Cookie.new({'name'  => 'rh_sso',
                                                  'value' => '123',
                                                  'path'  => '/',
                                                  'domain'=> '.redhat.com',
                                                  'secure'=> 'true'})

    # Create a cookie that should be left alone
    @request.cookies['keep'] = CGI::Cookie.new('keep', 'me')

    # Hit logout with some session data as well
    get(:show, {}, {:test => "value"})
    assert_redirected_to root_path

    # Make sure the cookie is gone and the session is empty
    assert session.empty?
    assert_nil cookies['rh_sso']

    # Make sure we didn't delete all cookies
    assert_not_nil cookies['keep']
  end

  test 'should recover from exceptions' do
    @controller.expects(:reset_sso).raises(AccessDeniedException)
    get :show
    assert_redirected_to root_path
  end

  test 'should redirect' do
    get :show, {:then => getting_started_path}
    assert_redirected_to getting_started_path
  end

  test 'should not redirect outside domain' do
    get :show, {:then => 'http://www.google.com/a_test_page'}
    assert_redirected_to '/a_test_page'
  end
end
