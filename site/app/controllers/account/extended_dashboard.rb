module Account
  module ExtendedDashboard
    extend ActiveSupport::Concern
    include DomainAware
    include AsyncAware

    def show
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

