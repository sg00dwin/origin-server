class EmbeddedCartridgesEventsController < BaseController
  respond_to :xml, :json
  before_filter :authenticate
  include LegacyBrokerHelper

  # POST /domain/[domain_id]/applications/[application_id]/cartridges/[cartridge_id]/events
  def create
    domain_id = params[:domain_id]
    id = params[:application_id]
    cartridge = params[:id]
    event = params[:event]

    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if(application.nil?)
      @reply = RestReply.new(:not_found)
      message = Message.new(:error, "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    if application.embedded.nil? or not application.embedded.include?(cartridge)
      @reply = RestReply.new( :bad_request)
      message = Message.new(:error, "The application #{id} is not configured with embedded cartridge #{cartridge}.") 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status 
      return
    end

    begin
      case event
        when 'start'
          application.start_dependency(cartridge)      
        when 'stop'
          application.stop_dependency(cartridge)      
        when 'restart'
          application.restart_dependency(cartridge)          
        when 'reload'
          application.reload_dependency(cartridge)
        else
          @reply = RestReply.new(:bad_request)
          message = Message.new(:error, "Invalid event #{event}")
          @reply.messages.push(message)
          respond_with @reply, :status => @reply.status   
          return
      end
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      message = Message.new(:error, "Failed to add event #{event} on cartridge #{cartridge} for application #{id}") 
      @reply.messages.push(message)
      message = Message.new(:error, e.message) 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    
    application = Application.find(cloud_user, id)
    app = RestApplication.new(application, domain_id)
    @reply = RestReply.new(:ok, "application", app)
    message = Message.new(:info, "Added #{event} on #{cartridge} for application #{id}")
    @reply.messages.push(message)
    respond_with @reply, :status => @reply.status
  end
end