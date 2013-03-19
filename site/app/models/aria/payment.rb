module Aria
  class Payment < Base

    def initialize(attrs)
      @attributes = attrs.is_a?(Aria::WDDX::Struct) ? attrs.attributes : attrs
    end

    def name
      "Payment: #{description}"
    end

    def date
      transaction_date
    end
  end
end
