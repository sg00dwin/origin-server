module Aria
  class RecurringLineItem < LineItem

    def recurring?
      true
    end
    def usage?
      false
    end
    def taxable?
      false
    end

    def name
      if service_name == 'Recurring' && plan_name
        "Plan: #{plan_name}"
      else description
      end
    end

    def total_cost
      amount
    end

    protected
      define_attribute_methods [:service_no,
                               :service_name,
                               :amount,
                               :description,
                               :plan_name]
  end
end
