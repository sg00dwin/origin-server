class AccountUpgradePaymentMethodController < PaymentMethodsController
  before_filter :aria_user, :only => [:edit, :show, :new]
  before_filter :payment_method, :only => [:edit, :show, :new]
  before_filter :billing_info, :only => [:edit, :new]
  before_filter :process_async

  def show
    redirect_to url_for(:action => :new) and return unless @payment_method.persisted?
    redirect_to next_path
  end

  def new
    @payment_method ||= Aria::PaymentMethod.new

    @payment_method = Aria::PaymentMethod.test if Rails.env.development?

    update_errors(@payment_method.errors, (params[:payment_method] || {})[:errors] || {})

    @payment_method.mode = Aria::DirectPost.get_or_create(params[:plan_id], url_for(:action => :direct_create))
    @payment_method.session_id = @aria_user.create_session
  end

  def direct_create
    if serve_direct?
      render :notify_parent, :layout => 'bare'
    else
      redirect_to next_path and return if @errors.empty?
      redirect_to url_for(:action => :new, :payment_method => {:errors => @errors})

    end
  end

  protected
    def next_path
      account_plan_upgrade_path
    end
    def post_name
      "edit_#{params[:plan_id]}"
    end
end
