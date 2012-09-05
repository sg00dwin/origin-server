class AccountUpgradesController < ApplicationController
  layout 'account'

  before_filter :authenticate_user!, :except => :show
  before_filter :authenticate_user_for_upgrade!, :only => :show

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

    aria_user = current_user.extend(Aria::User)

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

    aria_user = current_user.extend(Aria::User)
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
    @user = current_user
    @user.streamline_type!

    @user.extend Aria::User

    redirect_to edit_account_plan_upgrade_path and return unless @user.full_user? && @user.has_complete_account?
    redirect_to account_plan_upgrade_payment_method_path and return unless @user.has_valid_payment_method?
    redirect_to new_account_plan_upgrade_path
  end

  def edit
    @full_user = current_user.full_user
    @full_user = Streamline::FullUser.test if !@full_user.persisted? && Rails.env.development?

    @billing_info = current_user.extend(Aria::User).billing_info
    copy_user_to_billing(@full_user, @billing_info) unless @billing_info.persisted?
  end

  def update
    user_params = params[:streamline_full_user]
    @billing_info = Aria::BillingInfo.new user_params[:aria_billing_info]
    user = current_user
    @full_user = user.full_user

    unless @full_user.persisted?
      @full_user = Streamline::FullUser.new user_params
      render :edit and return unless user.promote(@full_user)
    end

    user.extend Aria::User
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

    def copy_user_to_billing(user, billing)
      [:first_name, :last_name,
       :address1, :address2, :address3,
       :city, :state, :country, :zip
      ].each{ |s| billing.send(:"#{s}=", user.send(s)) }
      billing
    end

    def copy_user_to_billing(user, billing)
      [:first_name, :last_name,
       :address1, :address2, :address3,
       :city, :state, :country, :zip
      ].each{ |s| billing.send(:"#{s}=", user.send(s)) }
      billing
    end
end
