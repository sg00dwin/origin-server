class ApplicationEstimateController < BaseController
  respond_to :xml, :json
  before_filter :authenticate
  
  # GET /estimates/application  
  def show
    app_descriptor = params[:descriptor]
    template = ApplicationTemplate.find(id_or_tag)
    @reply = RestReply.new(:ok, "application_estimates", templates)
    respond_with @reply, :status => @reply.status
  end
end
