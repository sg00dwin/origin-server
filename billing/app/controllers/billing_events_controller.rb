class BillingEventsController < BaseController
  respond_to :xml, :json

  # POST /events
  def create
    event_list_str = params[:event_id]
    
    # validate the :event_id param input
    
    event_list = event_list_str[1..-2].split(',').collect! {|n| n.to_i}

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
