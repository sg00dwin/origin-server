module OpenShift
  module Express
    class Page
      include ::OpenShift::CSSHelpers
      attr_accessor :fields, :items

      def initialize(page,path)
        @path = path
        @page = page
      end

      def open
        @page.open(@path)
      end

      def title
        @page.title
      end

      def click(selector)
        @page.click("css=#{selector}")
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
          "section##{x} a:contains('Sign up and try it')"
        }
      end
    end

    class Express < Page
      def initialize(page,path)
        super
        @items = {
          :whats_express => "What\'s Express?",
          :videos => 'Videos',
          :documentation => 'Documentation',
          :forum => 'Forum',
          :signup => 'Sign up to try Express!',
          :quickstart => 'Quickstart',
          :console => 'Express Console'
        }
      end

      def link(element)
        selector("a:contains('#{@items[element]}')")
      end

      def click(element)
        @page.click(link(element))
      end
    end

    class Flex < Page
      def initialize(page,path)
        super
        @items = {
          :whats_flex => "What\'s Flex?",
          :videos => 'Videos',
          :documentation => 'Documentation',
          :forum => 'Forum',
          :signup => 'Sign up to try Flex!',
          :quickstart => 'Quickstart',
          :console => 'Flex Console'
        }
      end

      def link(element)
        selector("a:contains('#{@items[element]}')")
      end

      def click(element)
        @page.click(link(element))
      end
    end
    
    class ExpressConsole < Page
      attr_accessor :domain_form

      def initialize(page,path)
        super
        @domain_form = OpenShift::Express::DomainForm.new(page, "new_express_domain")

      end
    end
  end
end
