module OpenShift
  module TestBase
    attr_accessor :data
    def initialize(name)
      super
      @data = Hash.new{|hash,key|
        array = [('a'..'z'),('A'..'Z'),(0..9)].map{|a| a.to_a}.flatten
        hash[key] = 10.times.map{array.respond_to?(:choice) ? array.choice : array.sample}.join
      }

      @valid_credentials = {
        :email => "flindiaksauce_valid@redhat.com",
        :password => "Pa$$word1"
      }
    end

    # unused
    def get_count(type)
      count = 0;
      result = self.instance_variable_get(:@_result)
      results = result.instance_variable_get("@#{type}".to_sym)
      
      results.each do |res| 
        count += 1 if res.test_name.start_with?(self.method_name)
      end
      return count > 0
    end

    def signout
      @logout.call
    end

    def signin(login=@valid_credentials[:email],password=@valid_credentials[:password])
        @login_page.open
        @login_page.submit(login, password)

        await("logout link", 10) {
          exists?("a.sign_out")
        }
    end
  end

  module CSSHelpers
    def exists?(css)
      begin
        @page.find_element(:css => css)
        return true
      rescue Selenium::WebDriver::Error::NoSuchElementError
        return false
      end
    end

    def text(css)
      @page.find_element(:css, css).text
    end

    def type(css,string)
      @page.find_element(:css, css).send_keys strin
    end

    def xpath_exists?(xpath)
      begin
        @page.find_element(:xpath => xpath)
        return true
      rescue Selenium::WebDriver::Error::NoSuchElementError
        return false
      end
    end

    # Needs to have navbar and signin defined,
    #   probably can figure out a better way
    def open_dialog(dialog, closeit=true)
      target = instance_variable_get("@#{dialog.to_s}")

      case dialog
      when :signin
        @home.open
        @navbar.click(:signin)
      else
        open_dialog(:signin)
        @signin.click(dialog)
      end

      if block_given?
        yield target
        if closeit
          target.click(:close)
        end
      end
    end

    def wait_for_ajax(timeout = 10)
      sleep 0.5 # ensure that AJAX has had a chance to start
      wait = Selenium::WebDriver::Wait.new(:timeout => timeout, :interval => 0.05)
      wait.until { @page.execute_script 'return jQuery.active == 0' }
    end

    # Wow, javascript in Selenium 1 is kludgy: http://bit.ly/oCzktV 
    def exec_js(script)
      @page.execute_script script
    end

    def sauce_testing(testing=true)
        exec_js("$.cookie('sauce_testing',#{testing});")
    end

    # helper method to wait for a (ruby) condition to become true
    def await(condition=nil, timeout=20)
      if block_given?
        secs = timeout
        while true
          begin
            if yield
              return
            else
              if !condition
                condition = "block to return true"
              end
              raise StandardError, "timed out after #{timeout} seconds waiting for #{condition}", caller
            end
          rescue
            sleep 1
            secs -= 1
            if secs <= 0
              raise
            end
          end
        end
      end
    end

    def wait_for_page(location, timeout=5)
      await("location: #{location}", timeout) {

        match = @page.current_url
        if not location.start_with?("http") #assume not absolute URL
          if match.start_with?($browser_url)
            # remove the browser url to get the relative path
            match = match[$browser_url.length..-1]
          else
            # just compare the path
            match = URI.parse(match).path
          end
        end

        location == match
      }
    end

   ##
   # wait_for_pages - checks for multiple pages as a way of
   # handling redirects
   def wait_for_pages(locations, timeout=5)
     uri = URI.parse(@page.current_url)
     match_list = []
     locations.each do |loc|
       match = loc.start_with?("http") ? #assume absolute URL
        uri.to_s : uri.to_s.split(uri.host)[1]
       match_list.push(match)
     end

     await("locations: #{locations.join(', ')}", timeout) {
       match_list.zip(locations) do |match, loc|
         if loc == match
           return true
         end
       end
       return false
     }
   end
  end

  module Assertions
    def assert_dialog_error(dialog,type,name,messages)
      err = dialog.error(type,name)
      assert        dialog.exists?(err), "#{err} does not exist"

      messages.each do |msg|
        assert_match  (dialog.messages[msg] || msg), dialog.text(err)
      end
    end

    def assert_redirected_to(location)
      wait_for_page location, 10
    end
    
    def assert_equal_no_case(expected, actual)
      assert_equal expected.downcase, actual.downcase
    end
  end
end
