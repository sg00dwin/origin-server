class BillingEventsController < BaseController
  include BillingHelper
  respond_to :xml, :json

  # POST /events
  def create
    event_list = params[:event_id]
    
    retval = "FAILED"
    begin
      event_list.each do |event_id|
        case event_id.to_s
        when  "101"
          Rails.logger.info("Received Account created event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when  "102"
          Rails.logger.info("Received Account administrative contact modified event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when  "103"
          Rails.logger.info("Received Account billing contact modified event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when  "104"
          Rails.logger.info("Received Account authentication data modified event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when  "105"
          Rails.logger.info("Received Account status changed event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when  "107"
          Rails.logger.info("Received Account master service plan modified event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when  "110"
          Rails.logger.info("Received Account supplemental service plan assigned event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when  "112"
          Rails.logger.info("Received Account supplemental service plan de-assigned event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when  "114"
          Rails.logger.info("Received Account supplemental service plan modified event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when "118" 
          Rails.logger.info("Received Account supplemental field value added event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when "119" 
          Rails.logger.info("Received Account supplemental field value modified event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when "120" 
          Rails.logger.info("Received Account supplemental field value deleted event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when "341" 
          Rails.logger.info("Received Invoice fully paid event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when "501" 
          Rails.logger.info("Received Account's unbilled usage value has crossed over client-defined MTD threshold value event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        when "503" 
          Rails.logger.info("Received Account's unbilled usage value has crossed over client-defined PTD threshold value event, id: #{event_id}")
          Rails.logger.info("The request params: #{params.inspect}")
          retval = "SUCCESS"
        else
          Rails.logger.error("ERROR: Received event with invalid id: #{event_id}")
          Rails.logger.error("ERROR: The request params: #{params.inspect}")
        end
        report_event(event_id.to_s, params)
      end
    end if event_list
    render :text => retval
  end

end
