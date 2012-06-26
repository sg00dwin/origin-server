class PlansController < SiteController
  def index
  end

  def edit
  end

  def update
    redirect_to account_plan_path, :success => 'upgraded'
  end

  def show
  end
end
