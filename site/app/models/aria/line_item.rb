module Aria
  class LineItem < Base
    attr_aria :name

    def initialize(attrs, plan_no)
      @attributes = attrs.is_a?(Aria::WDDX::Struct) ? attrs.attributes : attrs
      @persisted = true
      @plan_no = plan_no
    end

    protected
      attr_reader :plan_no
  end
end
