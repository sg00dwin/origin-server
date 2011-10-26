#!/usr/bin/env ruby
class Signup < Sauce::TestCase
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

  def test_signup_dialog
    tests = {
      :empty => [],
      :invalid => [ data[:username] ],
      :short_pass => [ "#{data[:username]}@#{data[:domain]}.com", data[:password][0,5] ],
      :mismatched => [ "#{data[:username]}@#{data[:domain]}.com", data[:password], data[:password2] ],
      :no_captcha => [ "#{data[:username]}@#{data[:domain]}.com", data[:password], data[:password] ],
      :success => [ "flindiak+sauce_#{data[:username]}@redhat.com", data[:password],data[:password], true ]
    }

    assertions = {
      :empty => lambda{|s| 
        [ :email, :password, :confirm ].each do |field|
          assert_dialog_error(s,:label,field,[:required_field])
        end
      },
      :invalid => lambda{|s|
        assert_dialog_error(s,:label,:email,[ :invalid_email ])
      },
      :short_pass => lambda{|s| 
        assert_dialog_error(s,:label,:password,[ :short_password ])
      },
      :mismatched => lambda{|s|
        assert_dialog_error(s,:label,:confirm,[ :mismatched_password ])
      },
      :no_captcha => lambda{|s|
        assert_dialog_error(s,:error,nil,[ :bad_captcha ])
      },
      :success => lambda{|s|
        @page.wait_for(:wait_for => :page)
        assert_redirected_to('/app/user/complete')
        #  section.main div.content p Check your inbox for an email with a validation link. Click on the link to complete the registration process. 
      }
    }

    tests.each do |name,args|
      open_dialog(:signup){ |signup|
        signup.submit(*args) #*args passes the array as individual elements
        assertions[name].call(signup)
      }
    end
  end

end
