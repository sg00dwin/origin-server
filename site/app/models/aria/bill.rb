module Aria
  class Bill
    def initialize(start_date, end_date, due_date, day, line_items, payments, unbilled_usage_line_items, unbilled_usage_balance, forwarded_balance=0)
      @start_date = start_date
      @end_date = end_date
      @due_date = due_date
      @day = day
      @invoice_line_items = line_items || []
      @invoice_payments = payments || []
      @unbilled_usage_line_items = unbilled_usage_line_items || []
      @unbilled_usage_balance = unbilled_usage_balance
      @forwarded_balance = forwarded_balance
    end

    attr_reader :start_date, :end_date, :due_date, :day, :invoice_line_items, :invoice_payments, :unbilled_usage_line_items, :forwarded_balance

    def payments
      @payments ||= invoice_payments
    end

    def show_payment_amounts
      payments.count != 1 || payments.first.amount != payments.first.applied_amount || payments.first.amount != balance
    end

    def line_items
      @line_items ||= invoice_line_items.concat(unbilled_usage_line_items)
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
  end
end
