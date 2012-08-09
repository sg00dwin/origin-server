module Account
  module ExtendedDashboard
    extend ActiveSupport::Concern
    include DomainAware
    include AsyncAware

    def show
      @user = current_user

      async do
        @user.load_email_address
        @identities = Identity.find @user
        @show_email = @identities.any? {|i| i.id != i.email }
      end

      async{ user_default_domain rescue nil }

      async{ @keys = Key.find :all, :as => @user }

      async do
        rest_user = User.find :one, :as => @user
        @plan = rest_user.plan rescue nil
      end
      join!

      render :show_extended, :layout => 'console'
    end
  end
end

