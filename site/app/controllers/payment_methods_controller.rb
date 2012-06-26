class PaymentMethodsController < SiteController

  def show
    @user = current_user
    @user.extend Aria::User
    @payment_method = @user.payment_method
    redirect_to new_account_plan_upgrade_payment_method_path and return unless @payment_method
  end

  def new
  end

  def create
  end

  def delete
  end

  def destroy
  end
end
