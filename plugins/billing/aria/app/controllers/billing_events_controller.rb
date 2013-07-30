class BillingEventsController < BillingController

  # POST /billing/rest/events
  def create
    retval = "FAILED"
    #Rails.logger.info("Request params: #{params.inspect}")
    begin
      aria_config = Rails.application.config.billing[:config]
      if aria_config[:enable_event_notification]
        event_list = params[:event_id]
        if event_list and (event_list - OpenShift::AriaEvent::EVENTS.keys()).empty?
          OpenShift::AriaEvent.handle_event(params)
          retval = "SUCCESS"
        else
          Rails.logger.error "ERROR: Received INVALID event, id: #{event_list}"
        end
      else
        retval = "Notification Disabled"
      end
    rescue Exception => e
      Rails.logger.error "ERROR: Processing event, #{e.message}"
      Rails.logger.error e.backtrace.inspect
    end
    render :text => retval
  end
end
