module OpenShift
  module Rest
    class NavBar
      include ::OpenShift::CSSHelpers

      def initialize(page,id)
        @page = page
        @id = id
        @base = "nav##{id}"
      end
    end

    class MainNav < NavBar
      @@items = {
        :signin => 'a.sign_in',
        :signout => 'a.sign_out',
        :user_dropdown => 'ul#utility-nav a.dropdown-toggle',

        :learn_more => 'a.learn_more',
        :getting_started => 'a.getting_started',
        :community => 'a.community',
        :developers => 'a.developers'
      }

      def link(name)
        @@items[name]
      end

      def links
        @@items
      end

      def click_signout
        @page.action.click(find_link(:user_dropdown)).click(find_link(:signout)).perform
      end

      def find_link(element)
        @page.find_element(:css, link(element))
      end

      def click(element)
        find_link(element).click
      end
    end
  end
end
