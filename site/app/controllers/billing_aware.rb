module BillingAware
  extend ActiveSupport::Concern

  included do
    include CapabilityAware
    helper_method :user_currency_cd, :user_can_upgrade_plan?, :user_on_basic_plan?
  end

  # Must be public for use in application_helper.rb
  def user_currency_cd
    if session[:currency_cd].blank? and user_can_upgrade_plan?
      aria_user = Aria::UserContext.new(current_user)
      session[:currency_cd] = aria_user.has_account? ? aria_user.currency_cd : Rails.configuration.default_currency.to_s
    end
    session[:currency_cd] || Rails.configuration.default_currency.to_s
  end

  protected

    #
    # Is the current user authorized to upgrade their plan?  Will lazily
    # load and cache the capabilities for the user.
    #
    # This is unrelated to the user's payment method, status_cd, etc
    # It is only used as a gatekeeper to hide upgrade function prior to general release
    #
    def user_can_upgrade_plan?
      Rails.configuration.aria_enabled && current_user && user_capabilities.plan_upgrade_enabled?
    rescue => e
      logger.error "Unable to check plan: #{e.message}\n  #{e.backtrace.join("\n  ")}"
      false
    end

    #
    # Is the user on the lowest plan tier?
    #
    def user_on_basic_plan?
      user_capabilities.plan_id == 'free'
    end

    #
    # Only users who can upgrade their plan can see the account upgrade flow
    #
    def user_can_upgrade_plan!
      redirect_to account_path unless user_can_upgrade_plan?
    end

    #
    # Return the login path if the user has previously_signed_in? or the
    # new account path if not.
    #
    def login_or_signup_path(path)
      if previously_signed_in?
        login_path(:then => path)
      else
        new_account_path(:then => path)
      end
    end

    def aria_user
      add_async(:aria_user => current_user)
    end

    def streamline_type
      user = current_user
      user.streamline_type!
      add_async(:aria_user => user)
    end

    def plan
      add_async(:plan => params[:plan_id])
    end

    def billing_info
      add_async(:billing_info)
    end

    def payment_method
      add_async(:payment_method)
    end

    def add_async(*args)
      @async ||= {}
      options = args.extract_options!
      @async.merge!(options)
      args.each do |arg|
        @async[arg] = true
      end
    end

    def process_async(*args)
      args = @async if args.empty?

      unless args.nil?
        async do
          @user = User.find :one, :as => current_user
          @plan = Aria::MasterPlan.cached.find(args[:plan])
          @current_plan = @user.plan
        end if args[:plan]

        async do
          @aria_user = Aria::UserContext.new(args[:aria_user])
          @payment_method = @aria_user.payment_method if args[:payment_method]
          @billing_info = @aria_user.billing_info if args[:billing_info]
        end

        join!
      end
    end
end
