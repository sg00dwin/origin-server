#!/usr/bin/env ruby
class AJAX < Sauce::TestCase
  include ::OpenShift::TestBase

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

  def test_dialogs
    # Toggle the dialogs by sending cmd to the old one
    #  If only one dialog is sent, assume we just want to check it and close it
    def toggle_dialogs(new,old=nil,cmd=nil)
      old.click(cmd) if cmd
      (assert !old.is_open?) if old
      assert new.is_open?
      new.click(:close)
      assert !new.is_open?
    end

    # Open the signin dialog
    open(:signin)
    toggle_dialogs(@signin)

    # Test signin -> reset
    open(:signin)
    toggle_dialogs(@reset,@signin,:reset)

    # Test reset -> signin
    open(:reset)
    toggle_dialogs(@signin,@reset,:signin)

    # Test signin -> signup
    open(:signin)
    toggle_dialogs(@signup,@signin,:signup)

    # Test signup -> signin
    open(:signup)
    toggle_dialogs(@signin,@signup,:signin)
  end

  def test_signin_dialog
    # Submit with no inputs
    open(:signin){ |signin|
      signin.submit
      # Make sure both errors exist and are correct
      [ :login, :password ].each do |field|
        assert_dialog_error(signin,:label,field,[:required_field])
      end
    }

    # Try an invalid login
    open(:signin){ |signin|
      signin.submit(data[:username],data[:password])
      assert_dialog_error(signin,:error,nil,[ :invalid ])
    }
  end

  def test_reset_dialog
    # Submit with no inputs
    open(:reset){ |reset|
      reset.submit
      assert_dialog_error(reset,:label,:email,[ :required_field ])
    }

    # Try with an invalid email
    open(:reset){ |reset|
      reset.submit(data[:username])
      assert_dialog_error(reset,:label,:email,[ :invalid_email ])
    }

    # Try with a banned TLD
    open(:reset){ |reset|
      reset.submit("#{data[:username]}@#{data[:domain]}.ir")
      assert_dialog_error(reset,:error,nil,[ :invalid_email_supplied ])
    }

    # Try a valid request
    open(:reset){ |reset|
      email = "#{data[:username]}@#{data[:domain]}.com"
      reset.submit(email)
      assert_dialog_error(reset,:success,nil,[ :reset_success, /at #{email}\.$/ ])
    }
    
  end

  def assert_dialog_error(dialog,type,name,messages)
    err = dialog.error(type,name)
    assert        dialog.exists?(err), "#{err} does not exist"

    messages.each do |msg|
      assert_match  (dialog.messages[msg] || msg), dialog.text(err)
    end
  end

  def open(dialog)
    target = instance_variable_get("@#{dialog.to_s}")

    case dialog
    when :signin
      @navbar.click(:signin)
    else
      open(:signin)
      @signin.click(dialog)
    end

    if block_given?
      yield target
      target.click(:CLOSE)
    end
  end
end
