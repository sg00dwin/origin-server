class PlansController < BaseController

  skip_before_filter :authenticate_user!

  def index
    plans = []
    OpenShift::BillingService.instance.get_plans.each do |key, value|
      plan = RestPlan.new(key, value[:name], value[:plan_no], value[:capabilities], value[:usage_rates])
      plans.push(plan)
    end
    render_success(:ok, "plans", plans)
  end

  def show
    id = params[:id]
    OpenShift::BillingService.instance.get_plans.each do |key, value|
      return render_success(:ok, "plan",
                            RestPlan.new(key, value[:name], value[:plan_no], value[:capabilities], value[:usage_rates])) if key == id.to_sym
    end
    render_error(:not_found, "Plan not found.", 150)
  end
  
  def set_log_tag
    @log_tag = get_log_tag_prepend + "PLAN"
  end

  protected
    def get_url
      URI::join(request.url, "/broker/billing/rest").to_s
    end
end
