module OpenShift
  module Express
    class Dialog
      include ::OpenShift::CSSHelpers

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
          :required_field => /This field is required\./,
          :invalid => /Invalid username or password/,
          :invalid_email => /Please enter a valid email address\./,
          :invalid_email_supplied => /The email supplied is invalid/,
          :reset_success => /^The information you have requested has been emailed to you at /
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
        @fields = { }
      end

      def submit(email=nil)
        click(:submit)
      end
    end
  end
end
