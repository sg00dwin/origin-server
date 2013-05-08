module Aria
  class Invoice < Base

    def initialize(attrs, acct_no)
      @attributes = attrs.is_a?(Aria::WDDX::Struct) ? attrs.attributes : attrs
      @acct_no = acct_no
    end

    def usage_period_name
      usage_bill_from.to_date.strftime('%b') if usage_bill_from
    end

    def payments
      @payments ||= Aria.cached.get_payments_on_invoice(acct_no, invoice_no).map { |p| Aria::Payment.new(p) }
    end

    def statement_content
      Aria.cached.get_statement_for_invoice(acct_no, invoice_no).out_statement
    end

    def line_items
      @line_items ||= begin
        recurring = []
        usage = []
        Aria.cached.get_invoice_details(acct_no, invoice_no).each do |li| 
          if li.usage_type_no
            usage.push(li)
          else
            recurring.push(Aria::RecurringLineItem.new(li, master_plan_no))
          end
        end
        (recurring + UsageLineItem.for_usage(usage, master_plan_no)).sort_by(&Aria::LineItem.plan_sort)
      end
    end

    def <=>(other)
      if other.is_a? Aria::Invoice
        invoice_no <=> other.invoice_no
      else
        super
      end
    end

    protected
      attr_reader :acct_no
  end
end
