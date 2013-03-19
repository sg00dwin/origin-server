module Aria
  class LineItem < Base
    attr_aria :name
    attr_aria :date

    def recurring?
      false
    end
    def usage?
      false
    end
    def tax?
      false
    end

    def initialize(attrs, plan_no)
      @attributes = attrs.is_a?(Aria::WDDX::Struct) ? attrs.attributes : attrs
      @persisted = true
      @plan_no = plan_no
    end

    def self.plan_sort
      lambda { |li|
        if li.tax?
          [2, li.date || '9999-99-99', -li.total_cost]
        elsif li.usage?
          [1, li.date || '9999-99-99', (li.rate || 0)]
        else 
          [0, li.date || '9999-99-99', -(li.rate || 0)]
        end 
      }
    end

    protected
      attr_reader :plan_no

      def attribute_method?(attr_name)
        false #respond_to_without_attributes?(:attributes)
      end
  end
end
