class BillingInfoController < ApplicationController
  layout 'account'

  before_filter :authenticate_user!

  def edit
    @billing_info = current_user.extend(Aria::User).billing_info
  end

  def update
    user = current_user.extend Aria::User
    @billing_info = Aria::BillingInfo.new params[:aria_billing_info]
    render :edit and return unless user.update_account(:billing_info => @billing_info)
    redirect_to next_path
  end

  def next_path
    account_path
  end
  def previous_path
    next_path
  end
end
