module OpenShift
  module Express
    class Form
      include ::OpenShift::CSSHelpers
      attr_accessor :fields, :id

      def initialize(page,id)
        @id = id
        @page = page
      end

      def set_value(field,value)
        @page.type @fields[field], value
      end

      def get_value(field)
        @page.value @fields[field]
      end

      def in_error?(field)
        return @page.is_element_present "//*[@id='#{@fields[field]}' and @class='error']"
      end  

      def error_message(field)
        if in_error? field
          return @page.text "//label[@for='#{@fields[field]}' and @class='error']"
        else
          return nil
        end
      end

      def submit
        @page.click @submit
      end

      def processing?
        return @page.is_element_present "//form[@id='#{@id}']/div[@aria-role='progressbar']"
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
        return @page.element?(loc) && @page.visible?(loc)
      end

      def collapse
        if !collapsed?
	  @page.click(@loc_btn_cancel)
        end
      end

      def expand
        if collapsed?
	  @page.click(@loc_btn_edit)
        end
      end

      def get_collapsed_value(field)
        if :namespace == field
          return @page.text(@loc_namespace_collapsed)
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

      	@submit = "express_app_submit"
      end
    end

  end
end
