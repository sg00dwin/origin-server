#!/usr/bin/env ruby
class Reset < OpenShift::SeleniumTestCase

  def setup
    super
    @home.open
  end

# FIXME: reset is no longer a dialog but a page.  We need to do these same
#        tests on the reset password page

=begin
  def test_reset_dialog
    # Submit with no inputs
    open_dialog(:reset){ |reset|
      reset.submit
      assert_dialog_error(reset,:label,:email,[ :required_field ])
    }
    
    # Try with an invalid email
    open_dialog(:reset){ |reset|
      reset.submit(data[:username])
      assert_dialog_error(reset,:label,:email,[ :invalid_email ])
    }

    # Try with a banned TLD
    open_dialog(:reset){ |reset|
      reset.submit("#{data[:username]}@#{data[:domain]}.ir")
      assert_dialog_error(reset,:error,nil,[ :invalid_email_supplied ])
    }

    # Try a valid request
    open_dialog(:reset){ |reset|
      email = "#{data[:username]}@#{data[:domain]}.com"
      reset.submit(email)
      assert_dialog_error(reset,:success,nil,[ :reset_success, /at #{email}\.$/ ])
    }
  end
=end
end
