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
      #puts YAML.dump self.instance_variable_get(:@_result)
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
  end
end
