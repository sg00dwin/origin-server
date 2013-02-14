class AccountUpgradesController < ApplicationController
  include BillingAware

  layout 'account'

  before_filter :authenticate_user!, :except => :show
  before_filter :authenticate_user_for_upgrade!, :only => :show
  before_filter :user_can_upgrade_plan!

  rescue_from Aria::Error do |e|
    @message = case e
      when Aria::UserIdCollision; "Your account encountered a problem during the create account step.  Please contact technical support about the error: IDCOLLISION."
      when Aria::UserNoRHLogin; "Your account is not properly configured.  Please contact technical support about the error: MISSING_RHLOGIN(#{current_user.rhlogin})."
      when Aria::AuthenticationError; "Unable to authenticate to the Aria service."
      end
    render :error
  end

  def new
    plan_id = params[:plan_id]

    aria_user = Aria::UserContext.new(current_user)

    async do
      @user = User.find :one, :as => current_user
      @plan = Aria::MasterPlan.cached.find plan_id
      @current_plan = @user.plan
    end
    async do
      @payment_method = aria_user.payment_method
      @billing_info = aria_user.billing_info
    end
    join!

    render :unchanged and return if @plan == @current_plan
    render :downgrade and return if @plan.basic?
    render :change and return unless @current_plan.basic?
  end

  def create
    plan_id = params[:plan_id]

    aria_user = Aria::UserContext.new(current_user)
    @payment_method = aria_user.payment_method
    @billing_info = aria_user.billing_info

    @user = User.find :one, :as => current_user
    @plan = Aria::MasterPlan.cached.find plan_id
    @current_plan = @user.plan

    @user.plan_id = plan_id

    if @user.save
      redirect_to account_plan_path, :flash => {:success => 'upgraded'}
    else
      render :unchanged and return if @plan == @current_plan
      render :downgrade and return if @plan.basic?
      render :change and return unless @current_plan.basic?
      render :new
    end
  end

  def show
    user = current_user
    user.streamline_type!
    @user = Aria::UserContext.new(user)

    redirect_to edit_account_plan_upgrade_path and return unless @user.full_user? && @user.has_complete_account?
    redirect_to account_plan_upgrade_payment_method_path and return unless @user.has_valid_payment_method?
    redirect_to new_account_plan_upgrade_path
  end

  def edit
    user = Aria::UserContext.new(current_user)
    @full_user = user.full_user
    @full_user = Streamline::FullUser.test if !@full_user.persisted? && Rails.env.development?

    @billing_info = user.billing_info
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
      # Collect args for the streamline API
      full_user_params = user_params[:streamline_full_user]
      [:address1,:address2,:address3,:city,:state,:country].each do |field|
        full_user_params[field] = user_params[:aria_billing_info][field]
      end
      # ZIP is a funny case; Aria uses :zip but FullUser is more worldly and uses
      # :postal_code
      full_user_params[:postal_code] = user_params[:aria_billing_info][:zip]

      @full_user = Streamline::FullUser.new(full_user_params)

      # Attempt to promote
      render :edit and return unless @full_user.promote(user)
    end

    user = Aria::UserContext.new(user)
    begin
      render :edit and return unless user.create_account(:billing_info => @billing_info)
    rescue Aria::AccountExists
      render :edit and return unless user.update_account(:billing_info => @billing_info)
    end

    redirect_to account_plan_upgrade_payment_method_path and return unless user.has_valid_payment_method?
    redirect_to new_account_plan_upgrade_path
  end

  protected
    def authenticate_user_for_upgrade!
      redirect_to login_or_signup_path(account_plan_upgrade_path) unless user_signed_in?
    end

    def copy_user_to_billing(full_user, billing)
      # Here we must also transform between postal_code (FullUser) and zip (Aria)
      [:first_name, :last_name,
       :address1, :address2, :address3,
       :city, :state, :country, :postal_code
      ].each{ |s| attr = s == :postal_code ? :zip : s; billing.send(:"#{attr}=", full_user.send(s)) }
      billing
    end
end
