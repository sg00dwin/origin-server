#!/usr/bin/env ruby
class AJAX < Sauce::TestCase
  include ::OpenShift::TestBase
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

    # Try a valid login
    open(:signin){ |signin|
      signin.submit("flindiak+sauce_valid@redhat.com","Pa$$word1")
      @page.wait_for(:wait_for => :page)
      assert_redirected_to '/app/platform'
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

  def test_signup
    # Submit with no inputs
    open(:signup){ |signup|
      signup.submit
      # Make sure errors exist and are correct
      [ :email, :password, :confirm ].each do |field|
        assert_dialog_error(signup,:label,field,[:required_field])
      end
    }

    # Try with an invalid email
    open(:signup){ |signup|
      signup.submit(data[:username])
      assert_dialog_error(signup,:label,:email,[ :invalid_email ])
    }

    # Try with short password
    open(:signup){ |signup|
      email = "#{data[:username]}@#{data[:domain]}.com"
      signup.submit(email,data[:password][0,5])
      assert_dialog_error(signup,:label,:password,[ :short_password ])
    }

    # Try with mismatched passwords
    open(:signup){ |signup|
      email = "#{data[:username]}@#{data[:domain]}.com"
      signup.submit(email,data[:password],data[:password2])
      assert_dialog_error(signup,:label,:confirm,[ :mismatched_password ])
    }

    # Try with valid input but no captcha
    open(:signup){ |signup|
      email = "#{data[:username]}@#{data[:domain]}.com"
      signup.submit(email,data[:password],data[:password])
      assert_dialog_error(signup,:error,nil,[ :bad_captcha ])
    }

    # Try success with captcha bypass
    open(:signup){ |signup|
      email = "flindiak+sauce_#{data[:username]}@redhat.com"
      signup.submit(email,data[:password],data[:password],true)
      @page.wait_for(:wait_for => :page)
      assert_redirected_to('/app/user/complete')
    }

  end

  # Register
  #  section.main div.content p Check your inbox for an email with a validation link. Click on the link to complete the registration process. 
  # /app/user/complete

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
