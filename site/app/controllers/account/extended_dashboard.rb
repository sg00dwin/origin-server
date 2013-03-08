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

      @user = current_api_user
      @plan = @user.plan
      user = Aria::UserContext.new(current_user)
      @line_items = @plan.recurring_line_items.concat(user.unbilled_usage_line_items).select{ |li| li.total_cost > 0.0 }
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

