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

      user = Aria::UserContext.new(current_user)

      @user = current_api_user
      @plan = @user.plan

      unless user.has_account?
        render :dashboard_free and return
      end

      @current_usage_items = user.unbilled_usage_line_items
      @past_usage_items = user.past_usage_line_items
      @max_usage = [@current_usage_items, *@past_usage_items.values].map { |items| items.map(&:total_cost).sum }.max

      @line_items = @plan.recurring_line_items.concat(@current_usage_items).select{ |li| li.total_cost > 0.0 }

      @next_bill_estimate =
        @line_items.select(&:recurring?).map(&:total_cost).sum + 
        user.unbilled_balance

      @current_period_day = user.current_period_day
      @current_period = user.current_period_date_range
      @next_bill_date = @current_period.last + 1.day

      @current_balance = user.balance
      @bill_due_date = user.bill_due_date
      @has_payment_method = user.has_valid_payment_method?
      @payment_method = user.payment_method
    end

    def settings
      @user = current_user
      @identities = Identity.find @user
      @show_email = false

      async{ @domain = begin user_default_domain; rescue ActiveResource::ResourceNotFound; end }

      async{ @keys = Key.all :as => @user }
      async{ @authorizations = Authorization.all :as => @user }

      if user_can_upgrade_plan?
        async do
          api_user = current_api_user
          @plan = api_user.plan.tap{ |c| c.name }
        end
      end

      join!(30)

      if not @domain
        flash[:info] = "You need to set a namespace before you can create applications"
      elsif @keys.blank?
        flash[:info] = "You need to set a public key before you can work with application code"
      end
    end
  end
end

