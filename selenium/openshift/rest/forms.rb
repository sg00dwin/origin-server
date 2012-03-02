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
        error_field_name = :"#{field_name}_error"
        field = @fields[error_field_name]
        if field.nil?
          field = @fields[field_name]
        end
        xpath_exists?("//*[@id='#{field}' and contains(@class, 'error')]")
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
          :namespace => "domain_name",
          :namespace_error => "domain_name_group"
        }

      	@submit = "//input[@id='domain_submit']"

        @loc_btn_cancel = "//a[@href='/app/account']"
      end
    end

    class SshKeyForm < Form
      def initialize(page,id)
        super(page,id)
        @fields = {
          :name => "key_name",
          :name_error => "key_name_input",
          :key => "key_raw_content",
          :key_error => "key_raw_content_input"
        }

      	@submit = "//input[@id='key_submit']"

        @cancel_path = '/app/account'
        @loc_btn_cancel = "//a[@href='#{@cancel_path}']"
      end

      def cancel
        @page.find_element(:xpath => @loc_btn_cancel).click
        wait_for_page @cancel_path
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
  end
end
