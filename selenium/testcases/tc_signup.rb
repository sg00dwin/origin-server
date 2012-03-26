require 'openshift/selenium_test_case'

class Signup < OpenShift::SeleniumTestCase

# FIXME: signup is now a page, not a dialog so we need to fix the code to
#        reflect that

=begin
  def setup
    super
    @home.open

    @tests = {
      :empty => [],
      :invalid => [ data[:username] ],
      :short_pass => [ "#{data[:username]}@#{data[:domain]}.com", data[:password][0,5] ],
      :mismatched => [ "#{data[:username]}@#{data[:domain]}.com", data[:password], data[:password2] ],
      :bad_domain => [ "#{data[:username]}@#{data[:domain]}.ir", data[:password], data[:password], true ],
      :success => [ "flindiak+sauce_#{data[:username]}@redhat.com", data[:password],data[:password], true ]
    }
  end

  def test_signup_dialog
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

      # These errors are generated server side
      :no_captcha => lambda{|s|
        assert_dialog_error(s,:error,nil,[ :bad_captcha ])
      },
      :bad_domain => lambda{|s|
        assert_dialog_error(s,:error,nil,[ :bad_domain ])
      },

      # This should succeed
      :success => lambda{|s|
        assert_redirected_to('/app/user/complete')
      }
    }

    @tests.each do |name,args|
      open_dialog(:signup, name != :success){ |signup|
        signup.submit(*args) #*args passes the array as individual elements
        assertions[name].call(signup)
      }
    end
  end
=end
end
