module Aria
  class Invoice < Base

    def initialize(attrs, acct_no)
      @attributes = attrs.is_a?(Aria::WDDX::Struct) ? attrs.attributes : attrs
      @acct_no = acct_no
    end

    def period_name
      bill_date.to_date.strftime('%b')
    end

    def payments
      @payments ||= Aria.cached.get_payments_on_invoice(acct_no, invoice_no).map { |p| Aria::Payment.new(p) }
    end

    def line_items
      @line_items ||= Aria.cached.get_invoice_details(acct_no, invoice_no).map {|li| 
        if li.usage_type_no
          Aria::UsageLineItem.for_usage(li, master_plan_no)
        else
          Aria::RecurringLineItem.new(li, master_plan_no)
        end
      }
    end

    protected
      attr_reader :acct_no
  end
end
