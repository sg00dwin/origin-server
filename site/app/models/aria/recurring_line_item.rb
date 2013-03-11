module Aria
  class RecurringLineItem < LineItem

    def recurring?
      true
    end
    def usage?
      false
    end
    def taxable?
      taxable_ind == 1
    end

    def name
      case client_coa_code
      when 'recurring' then "Plan: MegaShift"
      else service_desc
      end
    end

    def monthly_fee
      Aria.cached.get_client_plan_service_rates(plan_no, service_no).first.monthly_fee
    end
    alias_method :total_cost, :monthly_fee

    protected
      define_attribute_methods [:service_no,
                               :service_desc,
                               :taxable_ind,
                               :client_coa_code]
  end
end
