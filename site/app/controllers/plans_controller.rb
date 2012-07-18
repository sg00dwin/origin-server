class PlansController < AccountController
  def plans
    [Plan.new(:id => 'freeshift', :name => 'FreeShift'), Plan.new(:id => 'megashift', :name => 'MegaShift')]
  end

  def index
    @plans = plans
  end

  def edit
  end

  def update
    @user = User.new({:login => current_user.login, :plan_id => params[:plan_id], :as => current_user}, true)
    if @user.save
      redirect_to account_plan_path, :flash => {:success => 'upgraded'}
    else
      render :edit
    end
  end

  def show
    @user = User.find :one, :as => current_user
    logger.debug "User #{@user.inspect}"
    @plan = plans.find{ |p| p.id == @user.plan_id } || plans.first
  end
end
