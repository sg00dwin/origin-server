class PaymentMethodsController < AccountController

  before_filter :authenticate_user!

  def show
    @user = current_user
    @user.extend Aria::User
    @payment_method = @user.payment_method
    redirect_to new_account_plan_upgrade_payment_method_path and return unless @payment_method.persisted?
    redirect_to new_account_plan_upgrade_path
  end

  def new
    @user = current_user.extend Aria::User
    @payment_method = @user.payment_method || Aria::PaymentMethod.new
    if @payment_method.persisted?
      @previous_payment_method = @payment_method.dup
      @payment_method.cc_no = nil
      @previous_url = new_account_plan_upgrade_path
    elsif Rails.env.development?
      @payment_method = Aria::PaymentMethod.test
    end
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
    @payment_method = @user.payment_method
    @previous_payment_method = @payment_method.dup
    @previous_url = account_path
    @payment_method.cc_no = nil
    @payment_method.mode = Aria::DirectPost.get_or_create(nil, direct_update_account_payment_method_url)
    @payment_method.session_id = @user.create_session
  end

  def direct_update
    @next_url = account_path

    if serve_direct?
      render :notify_parent, :layout => 'bare'
    else
      redirect_to @next_url and return if @errors.empty?
      redirect_to edit_account_payment_method_path, :flash => {:error => to_flash(@errors)}
    end
  end

  def delete
  end

  def destroy
  end

  protected
    def serve_direct?
      logger.debug params.inspect
      @errors = (params[:error_messages] || {}).values.map{ |v| v['error_key'] }.uniq.map do |s|
        I18n.t(s, :scope => [:aria, :direct_post], :default => s)
      end
      @user = current_user.extend Aria::User
      unless @user.has_valid_payment_method?
        @errors << I18n.t(:unknown, :scope => [:aria, :direct_post])
      end
      params[:params] && params[:params][:params] == 'serve_direct'
    end

    def to_flash(errors)
      return errors.first if errors.length == 1
      "Your payment information could not be processed.<ul><li>#{errors.join("</li><li>")}</li></ul>".html_safe
    end

    def text
      TextHelper.instance
    end
    class TextHelper
      include Singleton
      include ActionView::Helpers::TextHelper
    end
end
