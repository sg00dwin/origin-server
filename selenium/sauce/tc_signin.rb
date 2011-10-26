#!/usr/bin/env ruby
class Signin < Sauce::TestCase
  include ::OpenShift::TestBase
  include ::OpenShift::CSSHelpers
  include ::OpenShift::Assertions

  def setup
    super
    @page = page
    @home = OpenShift::Express::Page.new(page, '/app')
    @navbar  = OpenShift::Express::MainNav.new(page,'main_nav')
    @signin  = OpenShift::Express::Login.new(page,'signin')
    @reset   = OpenShift::Express::Reset.new(page,'reset_password')
    @signup  = OpenShift::Express::Signup.new(page,'signup')

    @home.open
  end

  def test_signin_dialog
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

    # Try a valid login
    open_dialog(:signin){ |signin|
      signin.submit("flindiak+sauce_valid@redhat.com","Pa$$word1")
      @page.wait_for(:wait_for => :page)
      assert_redirected_to '/app/platform'
    }
  end
end
