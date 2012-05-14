require 'selenium/webdriver/support/select'

module OpenShift
  module Rest
    class Form
      include ::OpenShift::CSSHelpers
      attr_accessor :fields, :id

      def initialize(page,id)
        @id = id
        @page = page
      end

      def set_value(field, value)
        el = @page.find_element(:id => @fields[field])
        if "select" == el.tag_name
          select = Selenium::WebDriver::Support::Select.new(el)
          select.select_by(:value, value)
        else
          el.clear
          el.send_keys value
        end
      end

      def get_value(field)
        el = @page.find_element(:id => @fields[field])
        if "textarea" == el.tag_name
          el.text
        else
          el.attribute "value"
        end
      end

      def in_error?(field_name)
        # check the field and the field error for an error class
        field = @fields[field_name]
        xpath_exists?("//*[@id='#{field}']/ancestor::div[contains(@class, 'control-group')][1][contains(@class, 'error')]")
      end

      def error_message(field)
        if in_error? field
           @page.find_element(:xpath => "//label[@for='#{@fields[field]}' and @class='error']").text
        else
          return nil
        end
      end

      def label(field)
        @page.find_element(:xpath => "//label[@for='#{@fields[field]}' and not(@class)]").text
      end

      def submit
        @page.find_element(:xpath => @submit).click
      end

      def processing?
        return xpath_exists?("//form[@id='#{@id}']//div[@aria-role='progressbar']")
      end
    end

    class DomainForm < Form
      def initialize(page,id)
        super(page,id)
        @fields = {
          :namespace => "domain_name"
        }

      	@submit = "//input[@id='domain_submit']"

        @loc_btn_cancel = "//a[contains(@href, '/account')]"
      end
    end

    class LoginForm < Form
      def initialize(page,id)
        super
        @fields = {
          :login => 'web_user_rhlogin',
          :password => 'web_user_password'
        }

        @submit = "//input[@id='web_user_submit']"
      end

      def submit(login=nil,password=nil)
        set_value(:login, login) if login
        set_value(:password, password) if password
        super()
      end
    end

    class SshKeyForm < Form
      def initialize(page,id)
        super(page,id)
        @fields = {
          :name => "key_name",
          :key => "key_raw_content"
        }

      	@submit = "//input[@id='key_submit']"

        @cancel_path = '/account'
        @loc_btn_cancel = "//a[contains(@href, @cancel_path)][contains(text(), 'Cancel')]"
      end

      def cancel
        @page.find_element(:xpath => @loc_btn_cancel).click
        wait_for_page "#{@cancel_path}"
      end
    end

    class ApplicationCreateForm < Form
      def initialize(page,id)
        super(page,id)
        @fields = {
          :name => "application_name",
          :namespace => "application_domain_name"
        }

      	@submit = "//input[@id='application_submit']"
      end
    end

    class ApplicationDeleteForm < Form
      def initialize(page,id)
        super(page,id)

        @submit = "//input[@id='application_submit']"
      end
    end

    class SignupForm < Form
      def initialize(page,id)
        super(page,id)
        @fields = {
          :name => "web_user_email_address",
          :password => "web_user_password",
          :confirm => "web_user_password_confirmation",
          :recaptcha => "recaptcha_response_field"
        }

        @submit = "//input[@id='web_user_submit']"
      end
    end
  end
end
