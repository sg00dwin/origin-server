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
      @identity = Identity.find(current_user).first

      user = Aria::UserContext.new(current_user)

      @user = current_api_user
      @plan = @user.plan

      unless user.has_account?
        render :dashboard_free and return
      end

      @is_test_user = user.test_user?

      @bill = user.next_bill

      @has_valid_payment_method = user.has_valid_payment_method?
      @payment_method = user.payment_method

      current_usage_items = @bill.unbilled_usage_line_items
      past_usage_items = user.past_usage_line_items
      if current_usage_items.present? and past_usage_items.present?
        @usage_items = { "Current" => current_usage_items }.merge(past_usage_items)
      else
        # TODO: remove, debug
        # @usage_items = {
        #   "Current" => current_usage_items
        # }.merge(
        #   {
        #     "Feb" => [
        #       OpenStruct.new({:units_label => 'hour', :units => 10, :total_cost => 1, :name => "Gear: Small"}),
        #       OpenStruct.new({:units_label => 'hour', :units => 10, :total_cost => 3, :name => "Gear: Medium"})
        #     ],
        #     "Jan" => [
        #       OpenStruct.new({:units_label => 'hour', :units => 30, :total_cost => 3, :name => "Gear: Small"}),
        #       OpenStruct.new({:units_label => 'hour', :units => 10, :total_cost => 3, :name => "Gear: Medium"})
        #     ]
        #   }
        # )
      end
      @usage_types = Aria::UsageLineItem.type_info(@usage_items.values.flatten) if @usage_items
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

