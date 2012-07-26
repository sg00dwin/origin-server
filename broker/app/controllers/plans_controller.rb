class PlansController < BaseController
  respond_to :xml, :json
  before_filter :authenticate, :check_version
  
  def index
    plans = []
    Express::AriaBilling::Plan.instance.plans.each do |key, value|
      plan = RestPlan.new(key, value[:name], value[:plan_no], value[:capabilities])
      plans.push(plan)
    end
    @reply = RestReply.new(:ok, "plans", plans)
    respond_with @reply, :status => @reply.status
  end

  def show
    id = params[:id]
    Express::AriaBilling::Plan.instance.plans.each do |key, value|
      Rails.logger.debug "plan #{key} #{value.inspect}"
      if key == id
        plan = RestPlan.new(key, value[:name], value[:plan_no], value[:capabilities])
        @reply = RestReply.new(:ok, "plan", plan)
        respond_with @reply, :status => @reply.status
      return
      end
    end
    @reply = RestReply.new(:not_found)
    @reply.messages.push(message = Message.new(:error, "Plan not found.", 150))
    respond_with @reply, :status => @reply.status
  end

  def get_url
    #Rails.logger.debug "Request URL: #{request.url}"
    url = URI::join(request.url, "/broker/billing/rest")
    #Rails.logger.debug "Request URL: #{url.to_s}"
    return url.to_s
  end

end
