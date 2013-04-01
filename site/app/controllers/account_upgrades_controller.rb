class AccountUpgradesController < ConsoleController
  include BillingAware

  before_filter :authenticate_user!, :except => :show
  before_filter :authenticate_user_for_upgrade!, :only => :show
  before_filter :user_can_upgrade_plan!

  before_filter :streamline_type, :only => :show
  before_filter :get_aria_user, :only => [:new, :create, :edit]

  before_filter :get_plan, :only => [:new, :create]
  before_filter :get_billing, :only => [:new, :create, :edit]

  before_filter :process_async

  rescue_from Aria::Error do |e|
    @message = case e
      when Aria::UserIdCollision; "Your account encountered a problem during the create account step.  Please contact technical support about the error: IDCOLLISION."
      when Aria::UserNoRHLogin; "Your account is not properly configured.  Please contact technical support about the error: MISSING_RHLOGIN(#{current_user.rhlogin})."
      when Aria::AuthenticationError; "Unable to authenticate to the Aria service."
      end
    render :error
  end

  def new
    render :unchanged and return if @plan == @current_plan
    render :downgrade and return if @plan.basic?
    render :change and return unless @current_plan.basic?
  end

  def create
    @user.plan_id = params[:plan_id]

    unless @payment_method.persisted? and @billing_info.persisted?
      @user.errors[:base] = "You must provide a method of payment and billing address for this account."
      render :new and return
    end

    if @user.save
      render :upgraded and return if (@current_plan.basic? and !@plan.basic?)
      redirect_to account_path, ({:flash => {:info => "Plan changed to #{@plan.name}"}} if @plan.id != @current_plan.id)
    else
      render :unchanged and return if @plan == @current_plan
      render :downgrade and return if @plan.basic?
      render :change and return unless @current_plan.basic?
      render :new
    end
  end

  def show
    redirect_to edit_account_plan_upgrade_path and return unless @aria_user.full_user? && @aria_user.has_complete_account?
    redirect_to account_plan_upgrade_payment_method_path and return unless @aria_user.has_valid_payment_method?
    redirect_to new_account_plan_upgrade_path
  end

  def edit
    @full_user = @aria_user.full_user
    @full_user = Streamline::FullUser.test if !@full_user.persisted? && Rails.env.development?

    copy_user_to_billing(@full_user, @billing_info) unless @billing_info.persisted?
  end

  def update
    user_params = params[:streamline_full_user]
    @billing_info = Aria::BillingInfo.new user_params[:aria_billing_info]
    user = current_user
    @full_user = user.full_user

    # Attempt to promote the streamline user to a full streamline user
    # if they aren't already
    unless @full_user.persisted?

      @full_user = Streamline::FullUser.new(
        {:postal_code => user_params[:aria_billing_info][:zip]}.
        merge!(user_params[:streamline_full_user]).
        merge!(user_params[:aria_billing_info].slice(:address1, :address2, :address3, :city, :region, :country))
      )

      render :edit and return unless @full_user.promote(user)
    end

    current_user_changed!
    get_aria_user

    begin
      render :edit and return unless @aria_user.create_account(:billing_info => @billing_info)
    rescue Aria::AccountExists
      render :edit and return unless @aria_user.update_account(:billing_info => @billing_info)
    end

    redirect_to account_plan_upgrade_payment_method_path and return unless @aria_user.has_valid_payment_method?
    redirect_to new_account_plan_upgrade_path
  end

  protected
    def get_aria_user(user = current_user)
      @aria_user = Aria::UserContext.new(user)
    end

    def streamline_type
      user = current_user
      user.streamline_type!
      get_aria_user(user)
    end

    def get_plan
      async do
        @user = User.find :one, :as => current_user
        @plan = Aria::MasterPlan.cached.find params[:plan_id]
        @current_plan = @user.plan
      end
      @async = true
    end

    def get_billing
      async do
        @payment_method = @aria_user.payment_method
        @billing_info = @aria_user.billing_info
      end
      @async = true
    end

    def process_async
      join! if @async
    end

    def authenticate_user_for_upgrade!
      redirect_to login_or_signup_path(account_plan_upgrade_path) unless user_signed_in?
    end

    def copy_user_to_billing(full_user, billing)
      # Here we must also transform between postal_code (FullUser) and zip (Aria)
      [:first_name, :last_name,
       :address1, :address2, :address3,
       :city, :state, :country, :postal_code
      ].each do |s|
        attr = case s
               when :postal_code
                 :zip
               when :state
                 :region
               else
                 s
               end
        billing.send(:"#{attr}=", full_user.send(s))
      end
      billing
    end

    def active_tab
      :account
    end
end
