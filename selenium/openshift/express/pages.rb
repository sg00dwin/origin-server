module OpenShift
  module Express
    class Page
      include ::OpenShift::CSSHelpers
      attr_accessor :fields, :items

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

    class Home < Page
      def initialize(page,path)
        super
        @fields = {
          :title => /^OpenShift by Red Hat$/,
        }

        @items = {
          :logo => 'header.universal div.content img'
        }

        @items[:signup_links] = %w(opener bottom_signup).map{|x| 
          "section##{x} a.sign_up"
        }
      end
      
      def click(css)
        @page.find_element(:css => css).click
      end
    end

    class Express < Page
      def initialize(page,path)
        super
        @items = {
          :whats_express => "What's Express?",
          :videos => 'Videos',
          :documentation => 'Documentation',
          :forum => 'Forum',
          :signup => 'Sign up to try Express!',
          :quickstart => 'Quickstart',
          :console => 'Express Console'
        }
      end
    end

    class Flex < Page
      def initialize(page,path)
        super
        @items = {
          :whats_flex => "What's Flex?",
          :videos => 'Videos',
          :documentation => 'Documentation',
          :forum => 'Forum',
          :signup => 'Sign up to try Flex!',
          :quickstart => 'Quickstart',
          :console => 'Flex Console'
        }
      end
    end
    
    class ExpressConsole < Page
      attr_accessor :domain_form, :app_form

      def initialize(page,path)
        super
        @domain_form = OpenShift::Express::DomainForm.new(page, "new_express_domain")
        @app_form = OpenShift::Express::AppForm.new(page, "new_express_app")
      end

      def ssh_key_form(name='new')
        OpenShift::Express::SshKeyForm.new(@page, "ssh_key_#{name}")
      end
    end
  end
end
