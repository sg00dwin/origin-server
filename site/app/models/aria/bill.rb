module Aria
  class Bill
    def initialize(attributes = {})
      @recurring_bill_from       = attributes[:recurring_bill_from]
      @recurring_bill_thru       = attributes[:recurring_bill_thru]
      @usage_bill_from           = attributes[:usage_bill_from]
      @usage_bill_thru           = attributes[:usage_bill_thru]
      @due_date                  = attributes[:due_date]
      @day                       = attributes[:day]
      @invoice_line_items        = attributes[:invoice_line_items] || []
      @invoice_payments          = attributes[:invoice_payments] || []
      @unbilled_usage_line_items = attributes[:unbilled_usage_line_items] || []
      @unbilled_usage_balance    = attributes[:unbilled_usage_balance] || 0
      @forwarded_balance         = attributes[:forwarded_balance] || 0
    end

    attr_reader :recurring_bill_from, :recurring_bill_thru, :usage_bill_from, :usage_bill_thru, :due_date, :day, :invoice_line_items, :invoice_payments, :unbilled_usage_line_items, :forwarded_balance

    def payments
      @payments ||= invoice_payments
    end

    def show_payment_amounts
      payments.count != 1 || payments.first.amount != payments.first.applied_amount || payments.first.amount != balance
    end

    def line_items
      @line_items ||= invoice_line_items + unbilled_usage_line_items
    end

    def balance
      @balance ||= (forwarded_balance + invoice_line_items.map(&:total_cost).sum + @unbilled_usage_balance).round(2)
    end
    alias_method :estimated_balance, :balance

    def empty?
      payments.blank? and 
      line_items.blank? and
      @forwarded_balance > -0.01 and @forwarded_balance < 0.01 and
      @unbilled_usage_balance < 0.01
    end

    def has_recurring?
      recurring_bill_from and recurring_bill_thru and line_items.find(&:recurring?)
    end

    def has_usage?
      usage_bill_from and usage_bill_thru and line_items.find(&:usage?)
    end
  end
end
