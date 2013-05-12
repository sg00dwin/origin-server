module Aria
  class RecurringLineItem < LineItem

    def self.find_all_by_plan_no(plan_no)
      plan = Aria.cached.get_client_plans_all.find{ |plan| plan.plan_no.to_s == plan_no.to_s }

      from_plan(plan)
    end

    def self.find_all_by_current_plan(acct_no)
      plan = Aria.cached.get_acct_plans_all(acct_no).last
      from_plan(plan)
    end

    def recurring?
      true
    end
    def tax?
      (service_name || '').include?('Tax')
    end

    def name
      if (service_name == 'Recurring' || service_name == 'Plan: Recurring') && plan_name
        "Plan: #{plan_name}"
      else 
        description
      end
    end

    def date
      date_range_start
    end

    def amount
      attributes['amount'] || (rate_per_unit * units)
    end
    alias_method :total_cost, :amount

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

      def self.from_error(msg, plan_name = "Unknown", plan_no = 0)
        new({
          'service_name' => 'Could not retrieve plan information. Please contact customer service.',
          'description' => 'Could not retrieve plan information. Please contact customer service.',
          'plan_name' => plan_name,
          'rate_per_unit' => 0,
          'units' => 1.0,
        }, plan_no)
      end

      def self.from_plan(plan)
        if plan.blank?
          Rails.logger.error "Unable to get recurring line items from plan"
          [from_error('Could not retrieve plan information. Please contact customer service.')]
        elsif plan.plan_services.blank?
          Rails.logger.error "Unable to get recurring line items from plan: #{plan.plan_name} (##{plan.plan_no})"
          [from_error('Could not retrieve plan service information. Please contact customer service.', plan.plan_name, plan.plan_no)]
        else
          items = []
          plan.plan_services.each do |s|
              begin
                next if s.blank? || s.is_recurring_ind == 0
                rate = s.plan_service_rates.select(&:monthly_fee).first.monthly_fee
                items << new({
                  'service_name' => s.service_desc,
                  'description' => s.service_desc,
                  'plan_name' => plan.plan_name,
                  'rate_per_unit' => rate,
                  'units' => 1.0,
                }, plan.plan_no) if rate >= 0.01
              rescue
                Rails.logger.error "Could not retrieve rates for #{s.service_desc} in plan #{plan.plan_name} (##{plan.plan_no})."
                items = [from_error('Could not retrieve plan rates. Please contact customer service.', plan.plan_name, plan.plan_no)]
                break
              end
          end
          items
        end
      end
  end
end
