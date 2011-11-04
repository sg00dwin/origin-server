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

    def setup
      @page    = page
      @home    = OpenShift::Express::Home.new(page, '/app')
      @express = OpenShift::Express::Express.new(page, '/app/express')
      @flex    = OpenShift::Express::Flex.new(page, '/app/flex')

      @navbar  = OpenShift::Express::MainNav.new(page,'main_nav')
      @signin  = OpenShift::Express::Login.new(page,'signin')
      @reset   = OpenShift::Express::Reset.new(page,'reset_password')
      @signup  = OpenShift::Express::Signup.new(page,'signup')
    end

    def get_count(type)
      count = 0;
      result = self.instance_variable_get(:@_result)
      results = result.instance_variable_get("@#{type}".to_sym)
      
      results.each do |res| 
        count += 1 if res.test_name.start_with?(self.method_name)
      end
      return count > 0
    end

    def teardown
      if(get_count('errors') || get_count('failures'))
        page.failed!
      else
        page.passed!
      end
    end

    def signin
      open_dialog(:signin, false){ |signin|
        signin.submit(@valid_credentials[:email],@valid_credentials[:password])
          
        # a successful sign in will redirect you
        @page.wait_for_page
      }
    end
  end

  module CSSHelpers
    def selector(field)
      "css=#{@base} #{field}"
    end

    def exists?(css)
      @page.element?(css)
    end

    def text(css)
      @page.get_text(css)
    end

    def type(css,string)
      @page.type(css,string)
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

    # Wow, javascript in Selenium 1 is kludgy: http://bit.ly/oCzktV 
    def exec_js(script)
      @page.get_eval("
        (function(){with(this){
        #{script}
          }}).call(selenium.browserbot.getUserWindow());
        ");
    end

    def sauce_testing(testing=true)
        exec_js("$.cookie('sauce_testing',#{testing});")
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

    def assert_redirected_to(location,wait=true)
      @page.wait_for(:wait_for => :page) if wait

      uri = URI.parse(@page.location)
      match = location.start_with?("http") ? #assume absolute URL
        uri.to_s : uri.to_s.split(uri.host)[1]

      assert_match /^#{match}$/, location
    end
  end
end
