class EventsController < BaseController
  respond_to :xml, :json
  before_filter :authenticate
  include LegacyBrokerHelper

  # POST /domains/[domain_id]/applications/[application_id]/events
  def create
    domain_id = params[:domain_id]
    id = params[:application_id]
    event = params[:event]
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if application.nil?
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    begin
      case event
        when "start"
          application.start
        when "stop"
          application.stop  
        when "force-stop"
          application.force_stop  
        when "restart"
          application.restart  
        else
          @reply = RestReply.new(:bad_request)
          message = Message.new("ERROR", "Invalid event #{event}.  Valid events are start, stop, restart, force-stop")
          @reply.messages.push(message)
          respond_with @reply, :status => @reply.status   
          return
        end
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      message = Message.new("ERROR", "Failed to add event #{event} to application #{id}") 
      @reply.messages.push(message)
      message = Message.new("ERROR", e.message) 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    
    application = Application.find(cloud_user, id)
    app = RestApplication.new(application, domain_id)
    @reply = RestReply.new(:ok, "application", app)
    message = Message.new("INFO", "Added #{event} to application #{id}")
    @reply.messages.push(message)
    respond_with @reply, :status => @reply.status
  end
  
end