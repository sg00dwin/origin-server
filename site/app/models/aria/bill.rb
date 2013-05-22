module Aria
  class Bill < Struct.new(:recurring_bill_from, :recurring_bill_thru, :usage_bill_from, :usage_bill_thru, :due_date, :paid_date, :day, :invoice_line_items, :invoice_payments, :unbilled_usage_line_items, :forwarded_balance)
    def initialize(attributes = {})
      super(*members.map {|m| attributes[m.to_sym]})
      self.invoice_line_items        ||= []
      self.invoice_payments          ||= []
      self.unbilled_usage_line_items ||= []
      self.forwarded_balance         ||= 0
    end

    alias_method :payments, :invoice_payments

    def show_payment_amounts?
      payments.count != 1 || payments.first.amount != payments.first.applied_amount || payments.first.amount != balance
    end

    def line_items
      @line_items ||= invoice_line_items + unbilled_usage_line_items
    end

    def balance
      @balance ||= (forwarded_balance + invoice_line_items.map(&:total_cost).sum + unbilled_usage_line_items.map(&:total_cost).sum).round(2)
    end
    alias_method :estimated_balance, :balance

    def empty?
      payments.blank? and 
      line_items.blank? and
      forwarded_balance > -0.01 and forwarded_balance < 0.01 and
      unbilled_usage_line_items.blank?
    end

    def has_recurring?
      !!(recurring_bill_from and recurring_bill_thru and line_items.find(&:recurring?))
    end

    def has_usage?
      !!(usage_bill_from and usage_bill_thru and line_items.find(&:usage?))
    end
  end
end
