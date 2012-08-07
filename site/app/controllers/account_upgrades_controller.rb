class AccountUpgradesController < AccountController

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

    @user = User.find(:one, :as => current_user)
    @plan = Plan.find plan_id
    @current_plan = @user.plan
    aria_user = current_user.extend(Aria::User)
    @payment_method = aria_user.payment_method

    render :unchanged if @plan == @current_plan
  end

  def create
    plan_id = params[:plan][:id]

    @user = User.find(:one, :as => current_user)
    @plan = Plan.find plan_id
    @current_plan = @user.plan

    @user.plan_id = plan_id

    logger.debug "@plan=#{@plan.inspect} @current_plan=#{@current_plan.inspect} @user=#{@user.inspect}"
    if @user.save
      redirect_to account_plan_path, :flash => {:success => 'upgraded'}
    else
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
    logger.debug "billing #{@billing_info.inspect}"
    copy_user_to_billing(@full_user, @billing_info) unless @billing_info.persisted?
    logger.debug "billing #{@billing_info.inspect}"
    # if user is full user, render as uneditable
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
      unless user_signed_in?
        path = if previously_signed_in?
          login_path(:then => account_plan_upgrade_path)
        else
          new_account_path(:then => account_plan_upgrade_path)
        end
        redirect_to path
      end
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
