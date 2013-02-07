class PlansController < ApplicationController
  include BillingAware

  layout 'account'

  before_filter :authenticate_user!
  before_filter :user_can_upgrade_plan!

  def index
    redirect_to :action => 'show'
  end

  def show
    @user = User.find :one, :as => current_user
    @plans = Aria::MasterPlan.cached.all
    @current_plan = @user.plan
    @smaller_plans, @bigger_plans = @plans.sort.split{ |p| p.id == @current_plan.id }
  end
end
