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

      def in_error?(field)
        xpath_exists?("//*[@id='#{@fields[field]}' and contains(@class, 'error')]")
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

        @loc_btn_cancel = "//a[@href='/app/account']"
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

        @loc_btn_cancel = "//a[@href='/app/account']"
      end
    end
  end
end
