class PaymentMethodsController < AccountController

  before_filter :authenticate_user!

  def show
    @user = current_user
    @user.extend Aria::User
    @payment_method = @user.payment_method
    redirect_to new_account_plan_upgrade_payment_method_path and return unless @payment_method
  end

  def new
    @user = current_user.extend Aria::User
    @payment_method = Rails.env.development? ? Aria::PaymentMethod.test : Aria::PaymentMethod.new
    @payment_method.mode = Aria::DirectPost.get_or_create(params[:plan_id], direct_create_account_plan_upgrade_payment_method_url)
    @payment_method.session_id = @user.create_session
  end

  def direct_create
    @next_url = new_account_plan_upgrade_path

    if serve_direct?
      render :notify_parent, :layout => 'bare'
    else
      redirect_to @next_url and return if @errors.empty?
      redirect_to new_account_plan_upgrade_payment_method_path, :flash => {:error => @errors}
    end
  end

  def edit
    @user = current_user.extend Aria::User
    @payment_method = Aria::PaymentMethod.find :one
    @payment_method.mode = Aria::DirectPost.get_or_create(nil, direct_update_account_payment_method_url)
    @payment_method.session_id = @user.create_session
  end

  def direct_update
    @next_url = account_path

    if serve_direct?
      render :notify_parent, :layout => 'bare'
    else
      redirect_to @next_url and return if @errors.empty?
      redirect_to edit_account_payment_method_path, :flash => {:error => @errors}
    end
  end

  def delete
  end

  def destroy
  end

  protected
    def serve_direct?
      logger.debug params.inspect
      @errors = (params[:error_messages] || {}).values.map{ |v| v['error_key'] }.uniq
      @user = current_user.extend Aria::User
      unless @user.has_valid_payment_method?
        @errors << 'Could not establish payment method'
      end
      params[:params] && params[:params][:params] == 'serve_direct'
    end

    def text
      TextHelper.instance
    end
    class TextHelper
      include Singleton
      include ActionView::Helpers::TextHelper
    end
end
