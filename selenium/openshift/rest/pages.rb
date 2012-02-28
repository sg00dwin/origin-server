module OpenShift
  module Rest
    class Page
      include ::OpenShift::CSSHelpers
      attr_accessor :fields, :items, :path

      def initialize(page, path)
        @path = path
        @page = page
      end

      def open
        @page.get @path
        wait_for_page @path
      end

      def title
        @page.find_element(:css, "title").text
      end

      def click(element)
        text = @items[element]
        @page.find_element(:link_text, text).click
      end
    end

    class Account < Page
      attr_accessor :domain_form, :domain_edit_page, :ssh_key_form

      def initialize(page,path)
        super
        @domain_form = OpenShift::Rest::DomainForm.new(page, "")
        @domain_edit_page = Page.new(page, "#{@path}/domain/edit")
        @ssh_key_form = OpenShift::Rest::SshKeyForm.new(page, "new_key")
      end

      def find_edit_namespace_button
        @page.find_element(:xpath => "//a[@href='/app/account/domain/edit']")
      end

      def find_ssh_key_row(key_name)
        @page.find_element(:css => ssh_key_row_selector(key_name))
      end

      def find_ssh_key_delete_button(key_name)
        @page.find_element(:css => ssh_key_row_selector(key_name, ' .delete_button'))
      end

      def find_ssh_key(key_name)
        @page.find_element(:css => ssh_key_row_selector(key_name, ' .sshkey')).text
      end

      def ssh_key_form(name='new')
        OpenShift::Rest::SshKeyForm.new(@page, "ssh_key_#{name}")
      end

      private

      def ssh_key_row_selector(key_name, postfix='')
        "##{key_name}_sshkey#{postfix}"
      end
    end

    class Console < Page
      attr_accessor :domain_form, :app_form

      def initialize(page,path)
        super
        #@domain_form = OpenShift::Express::DomainForm.new(page, "new_express_domain")
       # @app_form = OpenShift::Express::AppForm.new(page, "new_express_app")
      end
    end
  end
end
