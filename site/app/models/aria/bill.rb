module Aria
  class Bill
    def initialize(start_date, end_date, due_date, day, line_items, unbilled_usage_line_items, unbilled_usage_balance)
      @start_date = start_date
      @end_date = end_date
      @due_date = due_date
      @day = day
      @invoice_line_items = line_items
      @unbilled_usage_line_items = unbilled_usage_line_items
      @unbilled_usage_balance = unbilled_usage_balance
    end

    attr_reader :start_date, :end_date, :due_date, :day, :invoice_line_items, :unbilled_usage_line_items

    def line_items
      @line_items ||= invoice_line_items.concat(unbilled_usage_line_items)
    end

    def balance
      @balance ||= invoice_line_items.map(&:total_cost).sum + @unbilled_usage_balance
    end
    alias_method :estimated_balance, :balance

    def blank?
      balance < 0.01
    end
  end
end
