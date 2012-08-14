class PlansController < ApplicationController
  layout 'site'

  before_filter :authenticate_user!, :only => :show

  def index
    @plans = Aria::MasterPlan.cached.all
    if user_signed_in?
      @user = User.find :one, :as => current_user
      @current_plan = @user.plan
    end
  end

  def show
    @user = User.find :one, :as => current_user
    @plan = @user.plan
  end
end
