class EmbeddedCartridgesController < BaseController
  respond_to :xml, :json
  before_filter :authenticate
  include LegacyBrokerHelper

# POST /domains/[domain_id]/applications/[application_id]/cartridges
  def create
    domain_id = params[:domain_id]
    id = params[:application_id]
    cartridge = params[:id]
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if(application.nil?)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    if not check_cartridge_type(cartridge, container, "embedded")
      @reply = RestReply.new( :bad_request)
      carts = get_cached("cart_list_embedded", :expires_in => 21600.seconds) {
      Application.get_available_cartridges("embedded")}
      message = Message.new("ERROR", "Invalid cartridge #{cartridge}.  Valid values are (#{carts.join(', ')})") 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end

    begin
      app.add_dependency(@req.cartridge)
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      message = Message.new("ERROR", "Failed to add #{cartridge} to application #{app_name}") 
      @reply.messages.push(message)
      message = Message.new("ERROR", e.message) 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
      
    application = Application.find(cloud_user,id)
    app = RestApplication.new(application, domain_id)
    @reply = RestReply.new(:ok, "application", app)
    message = Message.new("INFO", "Added #{cartridge} to application #{id}")
    @reply.messages.push(message)
    return respond_with @reply, :status => @reply.status
  end
  
  # DELETE /domains/[domain_id]/applications/[id]/cartridges/[cartridge_id]
  def destroy
    domain_id = params[:domain_id]
    id = params[:application_id]
    cartridge = params[:id]
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if(application.nil?)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @reply.messages.push(message)
      return respond_with @reply, :status => @reply.status
    end
    
    if application.embedded.nil? or application.embedded != cartridge
      @reply = RestReply.new( :bad_request)
      message = Message.new("ERROR", "The application #{id} is not configured with embedded cartridge #{cartridge}.") 
      @reply.messages.push(message)
      return respond_with @reply, :status => @reply.status
    end

    begin
      app.remove_dependency(@req.cartridge)
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      message = Message.new("ERROR", "Failed to remove #{cartridge} from application #{app_name}") 
      @reply.messages.push(message)
      message = Message.new("ERROR", e.message) 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
      
    application = Application.find(cloud_user, id)
    app = RestApplication.new(application, domain_id)
    @reply = RestReply.new(:ok, "application", app)
    message = Message.new("INFO", "Removed #{cartridge} from application #{id}")
    @reply.messages.push(message)
    return respond_with @reply, :status => @reply.status
  end
  
  # POST /domain/[domain_id]/applications/[application_id]/cartridges/[cartridge_id]/events
  def update
    domain_id = params[:domain_id]
    id = params[:application_id]
    cartridge = params[:id]
    event = params[:event]

    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if(application.nil?)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    if application.embedded.nil? or application.embedded != cartridge
      @reply = RestReply.new( :bad_request)
      message = Message.new("ERROR", "The application #{id} is not configured with embedded cartridge #{cartridge}.") 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status 
      return
    end

    begin
      case event
        when 'start'
          app.start_dependency(cartridge)      
        when 'stop'
          app.stop_dependency(cartridge)      
        when 'restart'
          app.restart_dependency(cartridge)          
        when 'reload'
          app.reload_dependency(cartridge)
        else
          @reply = RestReply.new(:bad_request)
          message = Message.new("ERROR", "Invalid event #{event}")
          @reply.messages.push(message)
          respond_with @reply, :status => @reply.status   
          return
      end
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      message = Message.new("ERROR", "Failed to add event #{event} on cartridge #{cartridge} for application #{app_name}") 
      @reply.messages.push(message)
      message = Message.new("ERROR", e.message) 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    
    application = Application.find(cloud_user, id)
    app = RestApplication.new(application, domain_id)
    @reply = RestReply.new(:ok, "application", app)
    message = Message.new("INFO", "Added #{event} on #{cartridge} for application #{id}")
    @reply.messages.push(message)
    respond_with @reply, :status => @reply.status
  end
end