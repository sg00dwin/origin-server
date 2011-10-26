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
          :bad_captcha => %q{Captcha text didn't match}
        }
      end

      def link(name)
        selector(@@links[name])
      end

      def is_open?
        @page.is_visible(selector(''))
      end

      def click(link)
        @page.click(selector(@@links[link]))
      end

      def input(id)
        selector("input##{id}")
      end

      def error(type,name=nil)
        case type
        when :label
          selector("label.error[for=#{@fields[name]}]")
        when :error
          selector("div.message.error")
        when :success
          selector("div.message.success")
        when :notice
          selector("div.message.notice")
        end
      end

      def submit()
        click(:submit)
        @page.wait_for(:wait_for => :ajax, :javascript_framework => :jquery)
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
        super()
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
        super(page,id)
        @fields = { 
          :email => 'web_user_email_address',
          :password => 'web_user_password',
          :confirm => 'web_user_password_confirmation',
          :captcha => 'recaptcha_response_field',
        }
      end

      def captcha_secret
        'zvw5LiixMB0I4mjk06aR'
      end

      # Wow, javascript in Selenium 1 is kludgy: http://bit.ly/oCzktV 
      def exec_js(script)
        @page.get_eval("
          (function(){with(this){
          #{script}
            }}).call(selenium.browserbot.getUserWindow());
          ");
      end

      def submit(email=nil,password=nil,confirm=nil,captcha=false)
        type(input(@fields[:email]),email) if email
        type(input(@fields[:password]),password) if password
        type(input(@fields[:confirm]),confirm) if confirm

        # Need to clear out captcha_secret if it exists
        exec_js("
            $('#signup form').find('input[name=captcha_secret]').remove();
            $('#signup form').append(
              $('<input>')
                .attr('type','hidden')
                .attr('name','captcha_secret')
                .val('#{captcha ? captcha_secret : ''}')
              );
        ")

        click(:submit)
      end
    end
  end
end
