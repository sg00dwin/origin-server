module OpenShift
  module Express
    class Dialog
      include ::OpenShift::CSSHelpers

      attr_accessor :messages, :fields

      @@links = {
        :close  => 'a.close_button',
        :reset  => 'a.password_reset',
        :signup => 'a.sign_up',
        :signin => 'a.sign_in',
        :submit => 'input.button[type=submit]',
      }

      def initialize(page,id)
        @base = id
        @page = page

        @messages = {
          :required_field => /This field is required\./,
          :invalid => /Invalid username or password/,
          :invalid_email => /Please enter a valid email address\./,
          :invalid_email_supplied => /The email supplied is invalid/
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

    end

    class Login < Dialog
      def initialize(page,id)
        super(page,id)
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
        super(page,id)
        @fields = {
          :email => 'email_input',
        }
      end

      def submit(email=nil)
        type(input(@fields[:email]),email) if email
        click(:submit)
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

    class NavBar
      include ::OpenShift::CSSHelpers

      def initialize(page,id)
        @page = page
        @base = id
      end
    end

    class MainNav < NavBar
      @@items = {
        :signin => 'a.sign_in',
        :platform_overview => 'a.overview',
        :express => 'a.express',
        :flex => 'a.flex',
        :community => 'a.community'
      }

      def click(element)
        @page.click(selector(@@items[element]))
      end
    end
  end
end
