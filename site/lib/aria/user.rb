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

    def next_bill
      @next_bill ||= begin
          start_date = aria_datetime(current_period_start_date)
          next_bill_date = aria_datetime(account_details.next_bill_date)
          d = account_details
          Aria::Bill.new(
            start_date,
            next_bill_date - 1.day,
            next_bill_date,
            (Date.today - start_date).to_i + 1,
            unpaid_invoices.map(&:line_items).flatten(1),
            unbilled_usage_line_items,
            unbilled_usage_balance
          )
        end
    end

    def current_period_start_date
      [(account_details.last_bill_date || account_details.last_bill_thru_date), today].min
    end

    def unbilled_usage_line_items
      @unbilled_usage_line_items ||=
        Aria::UsageLineItem.for_usage(Aria.get_usage_history(acct_no, :date_range_start => current_period_start_date), account_details.plan_no)
    end

    def unbilled_usage_balance
      @unbilled_usage_balance ||=
        Aria.get_unbilled_usage_summary(acct_no).ptd_balance_amount.to_f
    end

    def unpaid_invoices
      invoices.reject{ |i| i.paid_date && i.paid_date <= today }
    end

    def paid_invoices
      invoices.select{ |i| i.paid_date.nil? or i.paid_date > today }
    end

    def invoices
      @invoices ||= Aria.cached.get_acct_invoice_history(acct_no).map {|i| Aria::Invoice.new(i, acct_no) }
    end

    def statements
      @statements ||= Aria.cached.get_acct_statement_history(acct_no)
    end

    def past_usage_line_items(periods=3)
      Hash[
        invoices.sort_by(&:bill_date).reverse.slice(0, periods).inject([]) { |a, i| 
          arr = [ i.period_name, i.line_items.select(&:usage?) ]
          a << arr if arr.last.present?
          a
        }
      ]
    end

    def downgraded_plan
      plan = queued_plans.last
      @queued_plan ||= ::OpenStruct.new(
        :name => plan.original_plan,
        :until_date => aria_datetime(plan.change_date)
      ) if plan && plan.new_plan_no != account_details.plan_no
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

      # If this fails, we're left with an existing user with an incorrect bill_day
      set_bill_day(params[:alt_bill_day])
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
      @billing_info = nil
      @account_details = nil
      @invoices = nil
      @unbilled_usage_balance = nil
      @unbilled_usage_line_items = nil
      #@tax_exempt = nil
      true
    rescue Aria::Error => e
      errors.add(:base, e.to_s)
      false
    end

    def set_bill_day(day)
      if day && account_details.bill_day != day
        next_date = account_details.next_bill_date.to_date
        target_date = next_date.change :day => day
        target_date = target_date.next_month if target_date < next_date

        @account_details = nil

        # Aria won't allow adjusting more than 27 days at a time
        delta = (target_date-next_date).to_i
        while delta > 0
          Aria.adjust_billing_dates :acct_no => acct_no, :action_directive => 1, :adjustment_days => [27,delta].min
          delta -= 27
        end
      end
    end

    def set_session_redirect(url)
      set_reg_uss_params('redirecturl', url)
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
        @today ||= Date.today.to_s
      end
  end

  class UserContext < SimpleDelegator
    include Aria::User
  end
end
