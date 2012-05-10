class BillingEventsController < BaseController
  respond_to :xml, :json

  # POST /events
  def create
    event_id = params[:event_id]

    begin
      case event_id
        when  "101"
          Rails.logger.info("Received event with id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          render :text => "SUCCESS"
        when "116"
          Rails.logger.info("Received event with id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          render :text => "SUCCESS"
        else
          Rails.logger.error("ERROR: Received event with invalid id: #{event_id}")
          Rails.logger.error("ERROR: The request params: #{params.inspect}")
          render :text => "FAILED"
        end
    end
  end

end