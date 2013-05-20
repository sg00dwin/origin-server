class PlansController < ConsoleController
  include BillingAware

  before_filter :authenticate_user!
  before_filter :user_can_upgrade_plan!

  def index
    redirect_to :action => 'show'
  end

  def show
    @user = User.find :one, :as => current_user
    @plans = Aria::MasterPlan.cached.all
    @current_plan = @user.plan
    if aria_user.has_account? and aria_user.account_status == :terminated
      @smaller_plans = @bigger_plans = []
    else
      @smaller_plans, @bigger_plans = @plans.sort.split{ |p| p.id == @current_plan.id }
    end
  end

  protected
    def active_tab
      :account
    end
end
