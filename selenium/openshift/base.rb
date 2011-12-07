module OpenShift
  module TestBase
    attr_accessor :data
    def initialize(name)
      super
      @data = Hash.new{|hash,key|
        array = [('a'..'z'),('A'..'Z'),(0..9)].map{|a| a.to_a}.flatten
        hash[key] = 10.times.map{array.choice}.join
      }

      @valid_credentials = {
        :email => "flindiak+sauce_valid@redhat.com",
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

    def signin(login=@valid_credentials[:email],password=@valid_credentials[:password])
      open_dialog(:signin, false){ |signin|
        signin.submit(login,password)
      
        await {
          exists?("a[href='/app/logout']")
        }
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
      sleep 0.1 # ensure that AJAX has had a chance to start
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
    def await(timeout=5)
      if block_given?
        wait = Selenium::WebDriver::Wait.new(:timeout => timeout)
        wait.until { yield }
      end
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
      uri = URI.parse(@page.current_url)
      match = location.start_with?("http") ? #assume absolute URL
        uri.to_s : uri.to_s.split(uri.host)[1]
      
      await { location == match }
    end
    
    def assert_equal_no_case(expected, actual)
      assert_equal expected.downcase, actual.downcase
    end
  end
end
