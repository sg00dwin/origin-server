class PlansController < BaseController
  respond_to :xml, :json
  before_filter :authenticate, :except => [:index, :show]
  before_filter :check_version
  
  def index
    plans = []
    Express::AriaBilling::Plan.instance.plans.each do |key, value|
      plan = RestPlan.new(key, value[:name], value[:plan_no], value[:capabilities])
      plans.push(plan)
    end
    render_success(:ok, "plans", plans, "LIST_PLANS")
  end

  def show
    id = params[:id]
    Express::AriaBilling::Plan.instance.plans.each do |key, value|
      return render_success(:ok, "plan", RestPlan.new(key, value[:name], value[:plan_no], value[:capabilities]),
                            "SHOW_PLAN") if key == id
    end
    render_error(:not_found, "Plan not found.", 150, "SHOW_PLAN")
  end

  def get_url
    url = URI::join(request.url, "/broker/billing/rest")
    return url.to_s
  end
end
