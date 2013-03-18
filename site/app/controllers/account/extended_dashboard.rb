module Account
  module ExtendedDashboard
    extend ActiveSupport::Concern
    include DomainAware
    include AsyncAware
    include SshkeyAware

    before_filter :require_login, :only => :show

    # trigger synchronous module load 
    [Key, Authorization, User, Domain, Plan] if Rails.env.development?

    def show
      @user_has_keys = sshkey_uploaded?
      @domain = user_default_domain rescue nil
      @identity = Identity.find(current_user).first

      user = Aria::UserContext.new(current_user)

      @user = current_api_user
      @plan = @user.plan

      unless user.has_account?
        render :dashboard_free and return
      end

      @current_usage_items = user.unbilled_usage_line_items
      @past_usage_items = user.past_usage_line_items
      @max_usage = [@current_usage_items, *@past_usage_items.values].map { |items| items.map(&:total_cost).sum }.max

      @bill = user.next_bill

      @has_valid_payment_method = user.has_valid_payment_method?
      @payment_method = user.payment_method
    end

    def settings
      @user = current_user
      @identities = Identity.find @user
      @show_email = false

      async{ @domain = begin user_default_domain; rescue ActiveResource::ResourceNotFound; end }

      async{ @keys = Key.all :as => @user }
      async{ @authorizations = Authorization.all :as => @user }

      join!(30)

      if not @domain
        flash[:info] = "You need to set a namespace before you can create applications"
      elsif @keys.blank?
        flash[:info] = "You need to set a public key before you can work with application code"
      end
    end
  end
end

