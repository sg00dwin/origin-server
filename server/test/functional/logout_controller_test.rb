require 'test_helper'
require 'cgi'

class LogoutControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_redirected_to login_path
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
    get(:index, {}, {:test => "value"})
    assert_redirected_to login_path

    # Make sure the cookie is gone and the session is empty
    assert session.empty?
    assert_nil cookies['rh_sso']

    # Make sure we didn't delete all cookies
    assert_not_nil cookies['keep']
  end
end
