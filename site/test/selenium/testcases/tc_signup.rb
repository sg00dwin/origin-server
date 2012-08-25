require 'openshift/selenium_test_case'

class Signup < OpenShift::SeleniumTestCase

  def setup
    super
    @home.open

    @tests = {
      :empty => [],
      :invalid => { :name => data[:username] },
      :short_pass => { :name => "#{data[:username]}@#{data[:domain]}.com",
                       :password => data[:password][0,5] },
      :mismatched => { :name => "#{data[:username]}@#{data[:domain]}.com",
                       :password => data[:password],
                       :confirm => data[:password2] },
      :bad_domain => { :name => "#{data[:username]}@#{data[:domain]}.ir",
                       :password => data[:password],
                       :confirm => data[:password],
                       :recaptcha => true },
=begin
      #FIXME: figure out how to bypass captcha
      :success => { :name => "flindiaksauce_#{data[:username]}@redhat.com",
                    :password => data[:password],
                    :confirm => data[:password],
                    :recaptcha => true }
=end
    }
  end

  def test_signup
    assertions = {
      :empty => lambda{
        [ :name, :password, :confirm ].each do |field|
           assert @signup.form.in_error? field
        end
      },
      :invalid => lambda{
        assert @signup.form.in_error? :name
      },
      :short_pass => lambda{
        assert @signup.form.in_error? :password
      },
      :mismatched => lambda{
        assert @signup.form.in_error? :confirm
      },

      :no_captcha => lambda{
        assert @signup.form.in_error? :captcha
      },

      :bad_domain => lambda{
        assert @signup.form.in_error? :name
      },

      # This should succeed
      :success => lambda{
        assert_redirected_to('/user/complete')
      }
    }

    @tests.each do |name, args|
      @signup.open
      args.each { |field, value| @signup.form.set_value(field, value) }
      @signup.form.submit
      assertions[name].call
    end
  end
end
