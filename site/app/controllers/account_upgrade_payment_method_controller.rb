class AccountUpgradePaymentMethodController < PaymentMethodsController
  def show
    @user = current_user
    @user.extend Aria::User
    @payment_method = @user.payment_method
    redirect_to url_for(:action => :new) and return unless @payment_method.persisted?
    redirect_to next_path
  end

  def new
    @user = current_user.extend Aria::User
    @payment_method = @user.payment_method || Aria::PaymentMethod.new
    @payment_method = Aria::PaymentMethod.test if Rails.env.development?
    @payment_method.mode = Aria::DirectPost.get_or_create(params[:plan_id], url_for(:action => :direct_create))
    @payment_method.session_id = @user.create_session
  end

  def direct_create
    if serve_direct?
      render :notify_parent, :layout => 'bare'
    else
      redirect_to next_path and return if @errors.empty?
      redirect_to url_for(:action => :new), :flash => {:error => @errors}
    end
  end

  protected
    def next_path
      new_account_plan_upgrade_path
    end
    def post_name
      "edit_#{params[:plan_id]}"
    end
end
