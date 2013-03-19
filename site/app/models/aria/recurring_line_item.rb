module Aria
  class RecurringLineItem < LineItem

    def self.find_all_by_plan_no(plan_no)
      plan_name = Aria.cached.get_client_plans_basic.find{ |plan| plan.plan_no.to_s == plan_no.to_s }.plan_name
      Aria.cached.get_client_plan_services(plan_no).keep_if{ |s| s.is_usage_based_ind == 0 }.map do |s| 
        rate = Aria.cached.get_client_plan_service_rates(plan_no, s.service_no).first.monthly_fee
        next if rate <= 0.01
        Aria::RecurringLineItem.new({
          'service_name' => s.service_desc,
          'description' => s.service_desc,
          'plan_name' => plan_name,
          'amount' => rate,
          'rate_per_unit' => rate,
          'units' => 1.0,
        }, plan_no)
      end.compact
    end

    def recurring?
      true
    end
    def tax?
      service_name.include?('Taxes')
    end

    def name
      if service_name == 'Recurring' && plan_name
        "Plan: #{plan_name}"
      elsif tax?
        "Tax: #{description}"
      else description
      end
    end

    def date
      date_range_start
    end

    def total_cost
      amount
    end

    def prorated?
      units != 1.0
    end

    def rate
      rate_per_unit
    end

    protected
      define_attribute_methods [:service_no,
                               :service_name,
                               :amount,
                               :units,
                               :rate_per_unit,
                               :description,
                               :plan_name,
                               :date_range_start]
  end
end
