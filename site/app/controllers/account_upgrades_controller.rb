class AccountUpgradesController < SiteController

  rescue_from Aria::Error do |e|
    @message = case e
      when Aria::UserIdCollision; "Your account encountered a problem during the create account step.  Please contact technical support about the error: IDCOLLISION."
      when Aria::UserNoRHLogin; "Your account is not properly configured.  Please contact technical support about the error: MISSING_RHLOGIN(#{current_user.rhlogin})."
      when Aria::AuthenticationError; "Unable to authenticate to the Aria service."
      end
    render :error
  end

  def new
  end

  def create
  end

  def upgrade
    @user = current_user
    @user.streamline_type!

    redirect_to edit_account_plan_upgrade_path and return unless @user.full_user?

    create_account
  end

  def edit
    @user = current_user
    @user.extend Streamline::FullUser
    # if user is full user, render as uneditable
  end

  def update
    @user = current_user
    @user.extend Streamline::FullUser
    @user.assign_attributes(params[:web_user])

    render :edit and return unless @user.promote

    create_account
  end

  protected
    def create_account
      @user.extend Aria::User
      unless @user.has_valid_account?
        if @user.create_account
          redirect_to account_plan_upgrade_payment_method_path
        else
          render :error
        end
        return
      end

      redirect_to account_plan_upgrade_payment_method_path and return unless @user.has_payment_method?

      render :new
    end
end
