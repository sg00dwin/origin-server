class PlansController < AccountController
  def index
    @plans = [Plan.new(:id => 'freeshift', :name => 'FreeShift'), Plan.new(:id => 'megashift', :name => 'MegaShift')]
  end

  def edit
  end

  def update
    redirect_to account_plan_path, :flash => {:success => 'upgraded'}
  end

  def show
    @plan = Plan.new(:id => 'freeshift', :name => 'FreeShift')
  end
end
