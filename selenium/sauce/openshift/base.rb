module OpenShift
  module TestBase
    attr_accessor :data
    def initialize(name)
      super
      @data = Hash.new{|hash,key|
        array = [('a'..'z'),('A'..'Z'),(0..9)].map{|a| a.to_a}.flatten
        hash[key] = 10.times.map{array.choice}.join
      }
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
    def open_dialog(dialog)
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
        target.click(:CLOSE)
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

    def assert_redirected_to(location,message=nil)
      uri = URI.parse(@page.location)
      assert_match /^#{uri.path}$/, location, message
    end
  end
end
