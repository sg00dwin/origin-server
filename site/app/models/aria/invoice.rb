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

    def statement_content
      Aria.get_statement_for_invoice(:acct_no => acct_no, :invoice_no => invoice_no).out_statement
    end

    def line_items
      @line_items ||= Aria.cached.get_invoice_details(acct_no, invoice_no).map {|li| 
        if li.usage_type_no
          Aria::UsageLineItem.new(li, master_plan_no)
        else
          Aria::RecurringLineItem.new(li, master_plan_no)
        end
      }.sort_by(&Aria::LineItem.plan_sort)
    end

    protected
      attr_reader :acct_no
  end
end
