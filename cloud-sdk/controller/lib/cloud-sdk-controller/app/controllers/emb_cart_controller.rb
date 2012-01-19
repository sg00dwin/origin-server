class EmbCartController < BaseController
  respond_to :xml, :json
  before_filter :authenticate
  include LegacyBrokerHelper

  # POST /domains/[domain_id]/applications/[application_id]/cartridges
  def create
    domain_id = params[:domain_id]
    id = params[:application_id]
    cartridge = params[:cartridge]
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if(application.nil?)
      @reply = RestReply.new(:not_found)
      message = Message.new(:error, "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    begin
      #container = Cloud::Sdk::ApplicationContainerProxy.find_available(application.server_identity)
      container = Cloud::Sdk::ApplicationContainerProxy.find_available(nil)
      if not check_cartridge_type(cartridge, container, "embedded")
        @reply = RestReply.new( :bad_request)
        carts = get_cached("cart_list_embedded", :expires_in => 21600.seconds) {
        Application.get_available_cartridges("embedded")}
        message = Message.new(:error, "Invalid cartridge #{cartridge}.  Valid values are (#{carts.join(', ')})") 
        @reply.messages.push(message)
        respond_with @reply, :status => @reply.status
        return
      end
    rescue Cloud::Sdk::NodeException => e
      @reply = RestReply.new(:service_unavailable)
      message = Message.new(:error, e.message) 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    

    begin
      application.add_dependency(cartridge)
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      message = Message.new(:error, "Failed to add #{cartridge} to application #{id}") 
      @reply.messages.push(message)
      message = Message.new(:error, e.message) 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
      
    application = Application.find(cloud_user,id)
    app = RestApplication.new(application, domain_id)
    @reply = RestReply.new(:ok, "application", app)
    message = Message.new(:info, "Added #{cartridge} to application #{id}")
    @reply.messages.push(message)
    respond_with @reply, :status => @reply.status
  end
  
  # DELETE /domains/[domain_id]/applications/[application_id]/cartridges/[cartridge_id]
  def destroy
    domain_id = params[:domain_id]
    id = params[:application_id]
    cartridge = params[:id]
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
      Rails.logger.debug "Removing #{cartridge} from application #{id}"
      application.remove_dependency(cartridge)
    rescue Exception => e
      Rails.logger.error "Failed to Remove #{cartridge} from application #{id}: #{e.message}"
      @reply = RestReply.new(:internal_server_error)
      message = Message.new(:error, "Failed to remove #{cartridge} from application #{id}") 
      @reply.messages.push(message)
      message = Message.new(:error, e.message) 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
      
    application = Application.find(cloud_user, id)
    app = RestApplication.new(application, domain_id)
    @reply = RestReply.new(:ok, "application", app)
    message = Message.new(:info, "Removed #{cartridge} from application #{id}")
    @reply.messages.push(message)
    respond_with @reply, :status => @reply.status
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