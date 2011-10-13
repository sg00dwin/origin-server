module OpenShift
  module TestBase
    def teardown
      passed = self.instance_variable_get(:@_result).passed? 

      if passed
        page.passed!
      else
        page.failed!
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
  end
end
