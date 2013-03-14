module Aria
  class LineItem < Base
    attr_aria :name

    def initialize(attrs, plan_no)
      @attributes = attrs.is_a?(Aria::WDDX::Struct) ? attrs.attributes : attrs
      @persisted = true
      @plan_no = plan_no
    end

    def self.plan_sort
      lambda { |li|
        if li.tax?
          [2, -li.total_cost]
        elsif li.usage?
          [1, li.rate]
        else 
          [0, -li.rate]
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
