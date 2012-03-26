require 'selenium/webdriver/support/select'

module OpenShift
  module Express
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
        xpath_exists?("//*[@id='#{@fields[field]}' and @class='error']")
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
          :namespace => "express_domain_namespace"
        }

      	@submit = "//div[@id='cp-dialog']//input[@id='express_domain_submit']"

        @loc_btn_edit = "//div[contains(@class, 'domain-widget')]//div[contains(@class,'popup-trigger')]/a"
        @loc_btn_cancel = "//div[@id='cp-dialog']/a[@class='os-close-link']"
        @loc_namespace_collapsed = "//div[@id='domains']//div[@class='current domain']"
      end

      def collapsed?
        return !inside_dialog?
      end

      def inside_dialog?
        loc = "//div[@id='cp-dialog']//form[@id='#{@id}']"
        return xpath_exists?(loc) && @page.find_element(:xpath => loc).displayed?
      end

      def collapse
        if !collapsed?
          @page.find_element(:xpath => @loc_btn_cancel).click
        end
      end

      def expand
        if collapsed?
          await("form collapsed") { xpath_exists?(@loc_btn_edit) }
          @page.find_element(:xpath => @loc_btn_edit).click
        end
      end

      def get_collapsed_value(field)
        if :namespace == field
          return @page.find_element(:xpath => @loc_namespace_collapsed).text
        end
      end
    end

    class AppForm < Form
      def initialize(page,id)
        super(page,id)
        @fields = {
          :app_name => "express_app_app_name",
          :cartridge => "express_app_cartridge"
        }

      	@submit = "//*[@id='express_app_submit']"
      end
    end

    class SshKeyForm < Form
      def initialize(page, id)
        super(page,id)
        prefix = id

        @fields = {
          :name => "#{prefix}_express_ssh_key_name",
          :key_string => "#{prefix}_express_ssh_key_key_string",
          :primary => "#{prefix}_express_ssh_key_primary",
          :mode => "#{prefix}_express_ssh_key_mode"
        }

        @submit = "//form[@id='#{id}']//input[@id='express_ssh_key_submit']"
      end
    end

  end
end
