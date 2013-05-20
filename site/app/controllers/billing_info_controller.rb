class BillingInfoController < ConsoleController
  include BillingAware

  before_filter :authenticate_user!
  before_filter :user_can_upgrade_plan!

  def edit
    @billing_info = aria_user.billing_info
  end

  def update
    @billing_info = Aria::BillingInfo.new(params[:aria_billing_info][:aria_billing_info], aria_user.has_account?)
    redirect_to next_path and return if aria_user.update_account(:billing_info => @billing_info)
    aria_user.errors[:base].each { |e| @billing_info.errors[:base] << e }
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
