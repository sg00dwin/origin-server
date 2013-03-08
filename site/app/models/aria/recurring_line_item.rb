module Aria
  class RecurringLineItem < LineItem

    protected
      define_attribute_methods [:service_no,
                               :service_desc,
                               :taxable_ind,
                               :client_coa_code]
    public
    alias_method :name, :service_desc

    def recurring?
      true
    end
    def usage?
      false
    end
    def taxable?
      taxable_ind == 1
    end

    def summary
      nil
    end

    def monthly_fee
      Aria.cached.get_client_plan_service_rates(plan_no, service_no).first.monthly_fee
    end
    alias_method :total_cost, :monthly_fee
  end
end
