require 'openshift/selenium_test_case'

class Signin < OpenShift::SeleniumTestCase

  def setup
    super
    @home.open
  end

  def test_signin_errors
    # Submit with no inputs
    @login_page.open
    @login_page.submit

    assert @login_page.login_form.in_error?(:password)

    ## Try an invalid login
    ## TODO: not possible on a dev env.  create a way to reproduce "bad logins"
    ## and re-enable
    #open_dialog(:signin){ |signin|
    #  signin.submit(data[:username],data[:password])
    #  assert_dialog_error(signin,:error,nil,[ :invalid ])
    #}
  end

  def test_signin_process
    sauce_testing

    # Try a valid login
    signin
    assert_redirected_to @rest_console.application_types_page.path

    @navbar.click_signout
    assert_redirected_to "/"
  end
end
