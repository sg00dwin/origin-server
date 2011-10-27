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
  end
end
