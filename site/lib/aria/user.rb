
require 'delegate'

module Aria
  module User
    # mixins for Aria user integration

    def acct_no
      @acct_no ||= Aria.cached.get_acct_no_from_user_id(user_id)
    end

    def has_account?
      acct_no.present?
    rescue AccountDoesNotExist
      false
    end

    def create_session
      @session_id ||= Aria.set_session(:user_id => user_id)
    end

    def destroy_session
      Aria.kill_session(:session_id => @session_id) if @session_id
      @session_id = nil
    rescue InvalidSession
      nil
    end

    def has_valid_account?
      values = Aria.cached.get_supp_field_values(acct_no, :rhlogin)
      raise Aria::UserNoRHLogin, acct_no if values.empty?
      raise Aria::UserIdCollision, acct_no unless values.include?(login)
      true
    rescue AccountDoesNotExist
      false
    end

    def has_complete_account?
      return false unless has_valid_account?
      billing_info.valid?
    rescue AccountDoesNotExist
      false
    end

    def account_details
      @account_details ||= begin
        Aria.get_acct_details_all(acct_no)
      end
    end

    def billing_info
      @billing_info ||= begin
        Aria::BillingInfo.from_account_details(account_details)
      rescue AccountDoesNotExist
        Aria::BillingInfo.new
      end
    end

    def has_valid_payment_method?
      account_details.status_cd.to_i > 0
    end

    def payment_method
      @payment_method ||= begin
        Aria::PaymentMethod.from_account_details(account_details)
      rescue AccountDoesNotExist
        Aria::PaymentMethod.new
      end
    end

    def tax_exempt
      # replace with call to get_tax_acct_status
      #@tax_exempt ||= (Aria.get_supp_field_value(acct_no, :tax_exempt) || 0).to_i
    end
    def tax_exempt?
      # tax_exempt > 0
      false
    end

    def test_user?
      account_details.is_test_acct == 'Y'
    end

    def bill_dates
      invoices_with_amounts.map(&:bill_date).uniq.sort.reverse!
    end

    def bill_for(invoice)
      return nil unless invoice
      start_date = aria_datetime(invoice.recurring_bill_from)
      end_date = aria_datetime(invoice.recurring_bill_thru)
      due_date = aria_datetime(invoice.bill_date)
      Aria::Bill.new(
        start_date,
        end_date,
        due_date,
        nil,
        invoice.line_items,
        invoice.payments,
        [],
        0
      )
    end

    def next_bill
      if @next_bill.nil?
        default_plan = Rails.configuration.aria_default_plan_no.to_s
        @next_bill =
          if account_details.plan_no.to_s == default_plan && next_plan_no == default_plan
            false
          else
            start_date = aria_datetime(current_period_start_date)
            next_bill_date = aria_datetime(account_details.next_bill_date)
            d = account_details
            Aria::Bill.new(
              start_date,
              next_bill_date - 1.day,
              next_bill_date,
              (Aria::DateTime.today - start_date).to_i + 1,
              unpaid_invoices.map(&:line_items).flatten(1).concat(next_plan_recurring_line_items),
              [],
              unbilled_usage_line_items,
              unbilled_usage_balance
            )
          end
      end
      @next_bill
    end

    def current_period_start_date
      [(account_details.last_bill_date || account_details.last_bill_thru_date), today].min
    end

    def unbilled_usage_line_items
      @unbilled_usage_line_items ||=
        Aria::UsageLineItem.for_usage(Aria.get_usage_history(acct_no, :date_range_start => current_period_start_date), account_details.plan_no).sort_by(&Aria::LineItem.plan_sort)
    end

    def unbilled_usage_balance
      @unbilled_usage_balance ||=
        Aria.get_unbilled_usage_summary(acct_no).ptd_balance_amount.to_f
    end

    def unpaid_invoices
      invoices.reject{ |i| i.paid_date }
    end

    def paid_invoices
      invoices.select{ |i| i.paid_date.nil? }
    end

    def invoices_with_amounts
      invoices.select {|i| i.debit != 0 || i.credit != 0 }
    end

    def usage_invoices
      invoices.select(&:usage_bill_from)
    end

    def invoices
      @invoices ||= Aria.get_acct_invoice_history(acct_no).map {|i| Aria::Invoice.new(i, acct_no) }.sort_by(&:bill_date).reverse!
    end

    def past_usage_line_items(periods=3)
      Hash[
        usage_invoices.slice(0, periods).inject([]) { |a, i| 
          arr = [ i.period_name, i.line_items.select(&:usage?) ]
          a << arr if arr.last.present?
          a
        }
      ]
    end

    def next_plan_no
      if plan = queued_plans.last
        plan.new_plan_no.to_s
      else
        account_details.plan_no
      end
    end

    def next_plan_recurring_line_items
      @next_plan_recurring_line_items ||= begin
          if plan = queued_plans.last
            Aria::RecurringLineItem.find_all_by_plan_no(plan.new_plan_no.to_s)
          else
            Aria::RecurringLineItem.find_all_by_current_plan(acct_no)
          end
        end
    end

    def queued_plans
      @queued_plans ||= Aria.get_queued_service_plans(acct_no)
    end

    def create_account(opts=nil)
      params = default_account_params
      validates = true
      opts.each_pair do |k,v|
        if v.respond_to? :to_aria_attributes
          params.merge!(v.to_aria_attributes)
        else
          params[k] = v
        end
        validates &= v.valid? if v.respond_to? :valid?
      end if opts
      return false unless validates

      Aria.create_acct_complete(params)
      true
    rescue Aria::AccountExists
      raise
    rescue Aria::Error => e
      errors.add(:base, e.to_s)
      false
    end

    def update_account(opts)
      params = HashWithIndifferentAccess.new
      validates = true
      opts.each_pair do |k,v|
        if v.respond_to? :to_aria_attributes
          params.merge!(v.to_aria_attributes)
        else
          params[k] = v
        end
        validates &= v.valid? if v.respond_to? :valid?
      end
      return false unless validates

      Aria.update_acct_complete(acct_no, params)
      (instance_variables - [:@delegate_sd_obj, :@acct_no]).each{ |s| remove_instance_variable(s) }
      #@tax_exempt = nil
      true
    rescue Aria::Error => e
      errors.add(:base, e.to_s)
      false
    end

    def cancel_queued_service_plan
      @queued_plans = nil
      Aria.cancel_queued_service_plan :account_number => acct_no
    end

    def set_session_redirect(url)
      set_reg_uss_params('redirecturl', url)
    end

    # Mostly for test use
    def clear_cache!
      @queued_plans = nil
      @billing_info = nil
      @account_details = nil
      @invoices = nil
      @next_plan_recurring_line_items = nil
      @unbilled_usage_balance = nil
      @unbilled_usage_line_items = nil
      @next_bill = nil
      @payment_method = nil
    end

    private
      def user_id
        Digest::MD5::hexdigest(login)
      end
      def random_password
        ::SecureRandom.base64(16)[0..12].gsub(/[^a-zA-Z0-9]/,'_') # Max allowed Aria limit
      end

      def set_reg_uss_params(name, value)
        Aria.set_reg_uss_params({
          :session_id => create_session,
          :param_name => name,
          :param_val => value,
        })
      end

      def default_account_params
        HashWithIndifferentAccess.new({
          :userid => user_id,
          :status_cd => 0,
          :master_plan_no => Aria.default_plan_no,
          :password => random_password,
          :alt_bill_day => 1,
          :test_acct_ind => Rails.application.config.aria_force_test_users ? 1 : 0,
          :supplemental => {:rhlogin => login},
        })
      end

      def aria_datetime(s)
        Date.strptime(s, '%Y-%m-%d').to_datetime
      end

      def today
        @today ||= Aria::DateTime.today.to_s
      end
  end

  class UserContext < SimpleDelegator
    include Aria::User
  end
end
