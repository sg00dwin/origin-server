class PlansController < ApplicationController
  layout 'account'

  before_filter :authenticate_user!

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
