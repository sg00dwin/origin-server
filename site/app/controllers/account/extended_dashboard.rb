module Account
  module ExtendedDashboard
    extend ActiveSupport::Concern
    include DomainAware
    include AsyncAware
    include SshkeyAware

    # trigger synchronous module load 
    [Key, Authorization, User, Domain, Plan] if Rails.env.development?

    def show
      @user_has_keys = sshkey_uploaded?
      @domain = user_default_domain rescue nil
      @identities = Identity.find current_user
      @show_email = false

      aria_user = current_aria_user

      @user = current_api_user

      unless user_can_upgrade_plan? and aria_user.has_account?
        render :dashboard_free and return
      end

      if not Rails.env.production? and params[:debug]
        # Never upgraded
        if params[:debug] == '0'
          render :dashboard_free and return
        end

        case params[:plan]
          when 'free'
            @plan = Plan.find :free
            @is_downgrading = false
          when 'downgrading'
            @plan = Plan.find :free
            @is_downgrading = true
          else # when 'silver'
            @plan = Plan.find :silver
            @is_downgrading = false
        end

        case params[:status]
          when 'terminated'
            @account_status = :terminated
          when 'suspended'
            @account_status = :suspended
          when 'dunning'
            @account_status = :dunning
          else # when 'normal'
            @account_status = :normal
        end

        case params[:payment]
          when 'bad'
            @payment_method = Aria::PaymentMethod.new({:cc_no => '1111', :cc_exp_mm => 12, :cc_exp_yyyy => 2015, :cvv => 111}, true)
            @has_valid_payment_method = false
          when 'missing'
            @payment_method = nil
            @has_valid_payment_method = false
          else  # when 'good'
            @payment_method = Aria::PaymentMethod.new({:cc_no => '1111', :cc_exp_mm => 12, :cc_exp_yyyy => 2015, :cvv => 111}, true)
            @has_valid_payment_method = true
        end

        case params[:last_bill]
          when 'unpaid'
            forwarded_balance = 100
            @last_bill = Aria::Bill.new(
              :usage_bill_from => '2010-01-01'.to_datetime,
              :usage_bill_thru => '2010-01-31'.to_datetime,
              :due_date => '2010-02-01'.to_datetime,
              :paid_date => nil,
              :invoice_line_items => [],
              :unbilled_usage_line_items => [],
              :forwarded_balance => 100
            )
          when 'none'
            forwarded_balance = 0
            @last_bill = nil
          else # when 'paid'
            forwarded_balance = 0
            @last_bill = Aria::Bill.new(
              :usage_bill_from => '2010-01-01'.to_datetime,
              :usage_bill_thru => '2010-01-31'.to_datetime,
              :due_date => '2010-02-01'.to_datetime,
              :paid_date => '2010-02-01'.to_datetime,
              :invoice_line_items => [],
              :unbilled_usage_line_items => [],
              :forwarded_balance => 100
            )
        end

        case params[:usage]
          when 'none'
            current_usage = []
            past_usage_items = {}
          when 'paid'
            current_usage = [
              Aria::UsageLineItem.new({'units_label' => 'gear-hour', 'units' => 50, 'rate_per_unit' => 0.04, 'amount' => 10, 'usage_type_description' => "Gear: Small"}, 123),
              Aria::UsageLineItem.new({'units_label' => 'gear-hour', 'units' => 100, 'rate_per_unit' => 0.08, 'amount' => 30, 'usage_type_description' => "Gear: Medium"}, 123)
            ]
            past_usage_items = {}
          when 'free'
            current_usage = [
              Aria::UsageLineItem.new({'units_label' => 'gear-hour', 'units' => 50, 'rate_per_unit' => 0.00, 'amount' => 0, 'usage_type_description' => "Gear: Small"}, 123)
            ]
            past_usage_items = {}
          when 'free_historical'
            current_usage = [
              Aria::UsageLineItem.new({'units_label' => 'gear-hour', 'units' => 50, 'rate_per_unit' => 0.00, 'amount' => 0, 'usage_type_description' => "Gear: Small"}, 123),
            ]
            past_usage_items = {
              "Feb" => [
                OpenStruct.new({:units_label => 'gear-hour', :units => 5, :total_cost => 0, :name => "Gear: Small"}),
              ],
              "Jan" => [
                OpenStruct.new({:units_label => 'gear-hour', :units => 30, :total_cost => 1, :name => "Gear: Small"}),
                OpenStruct.new({:units_label => 'gear-hour', :units => 60, :total_cost => 3, :name => "Gear: Medium"})
              ]
            }
          else # when 'paid_historical'
            current_usage = [
              Aria::UsageLineItem.new({'units_label' => 'gear-hour', 'units' => 50, 'rate_per_unit' => 0.04, 'amount' => 10, 'usage_type_description' => "Gear: Small"}, 123),
              Aria::UsageLineItem.new({'units_label' => 'gear-hour', 'units' => 100, 'rate_per_unit' => 0.08, 'amount' => 30, 'usage_type_description' => "Gear: Medium"}, 123)
            ]
            past_usage_items = {
              "Feb" => [
                OpenStruct.new({:units_label => 'gear-hour', :units => 5, :total_cost => 1, :name => "Gear: Small"}),
                OpenStruct.new({:units_label => 'gear-hour', :units => 10, :total_cost => 3, :name => "Gear: Medium"})
              ],
              "Jan" => [
                OpenStruct.new({:units_label => 'gear-hour', :units => 30, :total_cost => 1, :name => "Gear: Small"}),
                OpenStruct.new({:units_label => 'gear-hour', :units => 60, :total_cost => 3, :name => "Gear: Medium"})
              ]
            }
        end

        if @plan.id == 'free' and @is_downgrading == false and forwarded_balance == 0
          @bill = false
        else
          @bill = Aria::Bill.new(
            :usage_bill_from => '2010-02-01'.to_datetime,
            :usage_bill_thru => '2010-02-28'.to_datetime,
            :due_date => '2010-03-01'.to_datetime,
            :day => 17,
            :invoice_line_items => Aria::RecurringLineItem.find_all_by_plan_no(@plan.plan_no.to_s),
            :unbilled_usage_line_items => current_usage,
            :forwarded_balance => forwarded_balance
          )
        end

      else
        # Non-debug path
        @plan = @user.plan
        @is_test_user = aria_user.test_user?
        @is_downgrading = aria_user.default_plan_pending?
        @account_status = aria_user.account_status
        @virtual_time = Aria::DateTime.now if Aria::DateTime.virtual_time?

        @bill = aria_user.next_bill
        @last_bill = aria_user.last_bill

        @has_valid_payment_method = aria_user.has_valid_payment_method?
        @payment_method = aria_user.payment_method
      end

      if @bill 
        if @bill.unbilled_usage_line_items
          current_usage_items = @bill.unbilled_usage_line_items
          past_usage_items ||= aria_user.past_usage_line_items
          if current_usage_items.present? and past_usage_items.present?
            @usage_items = { "Current" => current_usage_items }.merge(past_usage_items)
          end
          @usage_types = Aria::UsageLineItem.type_info(@usage_items.values.flatten) if @usage_items
        end
      end

      @can_upgrade = (@is_downgrading || @plan.basic?) && @account_status != :terminated
    end
  end
end
