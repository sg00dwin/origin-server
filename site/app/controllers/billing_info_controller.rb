class BillingInfoController < ConsoleController
  include BillingAware

  before_filter :authenticate_user!
  before_filter :user_can_upgrade_plan!

  def edit
    @user = Aria::UserContext.new(current_user)
    @billing_info = @user.billing_info
  end

  def update
    @user = Aria::UserContext.new(current_user)
    @billing_info = Aria::BillingInfo.new params[:aria_billing_info][:aria_billing_info]
    redirect_to next_path and return if @user.update_account(:billing_info => @billing_info)
    @user.errors[:base].each { |e| @billing_info.errors[:base] << e }
    render :edit
  end

  def next_path
    account_path
  end
  def previous_path
    next_path
  end

  protected
    def active_tab
      :account
    end
end
