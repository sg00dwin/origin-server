class BillingEventsController < BaseController
  respond_to :xml, :json

  # POST /events
  def create
    event_list = params[:event_id]
    
    retval = "FAILED"
    begin
      event_list.each do |event_id|
        case event_id.to_s
          when  "101"
            Rails.logger.info("Received event with id: #{event_id}")
            Rails.logger.info("The request params: #{params.inspect}")
            retval = "SUCCESS"
          when "116"
            Rails.logger.info("Received event with id: #{event_id}")
            Rails.logger.info("The request params: #{params.inspect}")
            retval = "SUCCESS"
          else
            Rails.logger.error("ERROR: Received event with invalid id: #{event_id}")
            Rails.logger.error("ERROR: The request params: #{params.inspect}")
          end
      end
    end
    render :text => retval
  end

end
