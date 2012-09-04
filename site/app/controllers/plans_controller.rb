class PlansController < ApplicationController
  layout 'account'

  before_filter :authenticate_user!, :only => :show

  def index
    redirect_to :action => 'show'
  end

  def show
    @user = User.find :one, :as => current_user
    @plans = Aria::MasterPlan.cached.all
    @current_plan = Aria::MasterPlan.cached.find(@user.plan.id)
    @smaller_plans, @bigger_plans = @plans.split{ |p| p.id == @current_plan.id }
  end
end
