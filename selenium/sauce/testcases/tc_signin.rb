#!/usr/bin/env ruby
class Signin < Sauce::TestCase
  include ::OpenShift::TestBase
  include ::OpenShift::CSSHelpers
  include ::OpenShift::Assertions

  def setup
    super
    set_vars(page)
    @home.open
  end

  def test_signin_dialog_errors
    # Submit with no inputs
    open_dialog(:signin){ |signin|
      signin.submit
      # Make sure both errors exist and are correct
      [ :login, :password ].each do |field|
        assert_dialog_error(signin,:label,field,[:required_field])
      end
    }

    # Try an invalid login
    open_dialog(:signin){ |signin|
      signin.submit(data[:username],data[:password])
      assert_dialog_error(signin,:error,nil,[ :invalid ])
    }
  end

  def test_signin_process

    # Try a valid login
    signin
    assert_redirected_to '/app/platform'

    # Make sure that we're greeted
    assert_match "Greetings, #{@valid_credentials[:email]}!", @navbar.text(@navbar.link(:greeting))

    # Log out and make sure we're redirected
    @navbar.click(:signout)
    assert_redirected_to '/app/login'
  end
end
