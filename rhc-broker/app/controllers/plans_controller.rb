class PlansController < BaseController

  skip_before_filter :authenticate_user!

  def index
    plans = []
    Online::AriaBilling::Plan.instance.plans.each do |key, value|
      plan = RestPlan.new(key, value[:name], value[:plan_no], value[:capabilities], value[:usage_rates])
      plans.push(plan)
    end
    render_success(:ok, "plans", plans, "LIST_PLANS")
  end

  def show
    id = params[:id]
    Online::AriaBilling::Plan.instance.plans.each do |key, value|
      return render_success(:ok, "plan",
                            RestPlan.new(key, value[:name], value[:plan_no], value[:capabilities], value[:usage_rates]),
                            "SHOW_PLAN") if key == id.to_sym
    end
    render_error(:not_found, "Plan not found.", 150, "SHOW_PLAN")
  end

  protected
    def get_url
      URI::join(request.url, "/broker/billing/rest").to_s
    end
end
