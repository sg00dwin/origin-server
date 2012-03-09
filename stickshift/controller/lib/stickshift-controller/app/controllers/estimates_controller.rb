class EstimatesController < BaseController
  respond_to :xml, :json
  before_filter :authenticate

  # GET /estimates
  def index
    @reply = RestReply.new(:ok, "estimates", RestEstimates.new)
    respond_with @reply, :status => @reply.status
  end
end
