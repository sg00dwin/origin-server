module OpenShift
  module Express
    class Dialog
      include ::OpenShift::CSSHelpers
      include ::OpenShift::Assertions

      attr_accessor :messages, :fields, :id

      @@links = {
        :close  => 'a.close_button',
        :reset  => 'a.password_reset',
        :signup => 'a.sign_up',
        :signin => 'a.sign_in',
        :submit => 'input.button[type=submit]',
      }

      def initialize(page,id)
        @id = id
        @page = page
        @base = "div.dialog##{id}"

        @messages = {
          :required_field => %q{This field is required},
          :invalid => %q{Invalid username or password},
          :invalid_email => %q{Please enter a valid email address.},
          :invalid_email_supplied => %q{The email supplied is invalid},
          :reset_success => %q{The information you have requested has been emailed to you at},
          :short_password => %q{Please enter at least 6 characters.},
          :mismatched_password => %q{Please enter the same value again.},
          :bad_captcha => %q{Captcha text didn't match},
          :bad_domain => %q{We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy}
        }
      end

      def link(name)
        "#{@base} #{@@links[name]}"
      end

      def is_open?
        @page.find_element(:css, @base).displayed?
      end

      def click(link)
        @page.find_element(:css, link(link)).click
      end

      def input(id)
        "input##{id}"
      end
      
      def type(css_selector, text)
        @page.find_element(:css, css_selector).send_keys text
      end

      def error(type,name=nil)
        case type
        when :label
          "label.error[for=#{@fields[name]}]"
        when :error
          "div.message.error"
        when :success
          "div.message.success"
        when :notice
          "div.message.notice"
        end
      end

      def submit()
        click(:submit)
        wait_for_ajax
      end
    end

    class Login < Dialog
      def initialize(page,id)
        super
        @fields = {
          :login => 'login_input',
          :password => 'pwd_input'
        }
      end

      def submit(login=nil,password=nil)
        type(input(@fields[:login]),login) if login
        type(input(@fields[:password]),password) if password
        click(:submit)
      end
    end

    class Reset < Dialog
      def initialize(page,id)
        super
        @fields = {
          :email => 'email_input',
        }
      end

      def submit(email=nil)
        type(input(@fields[:email]),email) if email
        super()
      end
    end

    class Signup < Dialog
      def initialize(page,id)
        super
        @fields = { 
          :email => 'web_user_email_address',
          :password => 'web_user_password',
          :confirm => 'web_user_password_confirmation',
          :captcha => 'recaptcha_response_field',
        }
      end

      def submit(email=nil,password=nil,confirm=nil,captcha=false)
        type(input(@fields[:email]),email) if email
        type(input(@fields[:password]),password) if password
        type(input(@fields[:confirm]),confirm) if confirm

        sauce_testing(captcha)
        super()
      end
    end
  end
end
