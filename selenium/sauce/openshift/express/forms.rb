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
    end

    class DomainForm < Form
      def initialize(page,id)
        super(page,id)
        @fields = {
          :namespace => "express_domain_namespace",
          :ssh => "express_domain_ssh"
        }

      	@submit = "express_domain_submit"

        @loc_btn_edit = "//a[@class='button edit_domain' and text()='Edit']"
        @loc_btn_cancel = "//a[@class='button edit_domain' and text()='Cancel']"
        @loc_domain_form_collapsed = "domain_form_replacement"

        @loc_namespace_collapsed = "show_namespace"
        @loc_ssh_collapsed = "show_ssh"
      end

      def collapsed?
        return !@page.visible?(@id) && !@page.visible?(@loc_btn_cancel) && @page.visible?(@loc_domain_form_collapsed) && @page.visible?(@loc_btn_edit)
      end

      def update_mode?
        return @page.element?("//*[@id='new_express_domain' and contains(@class, 'update')]")
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
        elsif :ssh == field
          return @page.text(@loc_ssh_collapsed)
        end
      end
    end

  end
end
