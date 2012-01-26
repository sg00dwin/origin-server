class ApplicationsController < BaseController
  respond_to :xml, :json
  before_filter :authenticate
  include LegacyBrokerHelper
  
  # GET /domains/[domain id]/applications
  def index
    domain_id = params[:domain_id]
    cloud_user = CloudUser.find(@login)
    applications = Application.find_all(cloud_user)
    
    if applications.nil? 
      @reply = RestReply.new(:not_found)
      message = Message.new(:error, "No applications found for user #{@login}.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
    else
      apps = Array.new
      applications.each do |application|
        app = RestApplication.new(application, domain_id)
        apps.push(app)
      end
      @reply = RestReply.new(:ok, "application", apps)
      respond_with @reply, :status => @reply.status
    end
  end
  
  # GET /domains/[domain_id]/applications/<id>
  def show
    domain_id = params[:domain_id]
    id = params[:id]
    
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    
    if application.nil?
      @reply = RestReply.new(:not_found)
      message = Message.new(:error, "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
    else
      app = RestApplication.new(application, domain_id)
      @reply = RestReply.new(:ok, "application", app)
      respond_with @reply, :status => @reply.status
    end
  end
  
  # POST /domains/[domain_id]/applications
  def create
    domain_id = params[:domain_id]
    user = CloudUser.find(@login)
    app_name = params[:name]
    cartridges = params[:cartridges]
    if app_name.nil? 
      @reply = RestReply.new(:bad_request)
      message = Message.new(:error, "Missing required parameter: name.") 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    application = Application.find(user,app_name)
    if not application.nil?
      @reply = RestReply.new(:conflict)
      message = Message.new(:error, "The supplied application name '#{app_name}' already exists") 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    Rails.logger.debug "Checking to see if application name is black listed"
    if Cloud::Sdk::ApplicationContainerProxy.blacklisted? app_name
      @reply = RestReply.new(:forbidden)
      message = Message.new(:error, "The supplied application name '#{app_name}' is not allowed") 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end

    all_cart_names = Application.get_available_cartridges.map{|c| c.name}
    unless cartridges.nil?
      invalid_carts = []
      cartridges = cartridges.split(/\s*,\s*/)
      cartridges.each do |cart_name|
        invalid_carts.add cart_name unless all_cart_names.include? cart_name
      end
      
      unless invalid_carts.empty?
        @reply = RestReply.new(:bad_request)
        message = Message.new(:error, "Invalid cartridges #{invalid_carts.join(', ')}.  Valid values are (#{all_cart_names.join(', ')})") 
        @reply.messages.push(message)
        respond_with @reply, :status => @reply.status
        return
      end
    end
    
    Rails.logger.debug "Validating application"
    application = Application.new(user, domain_id, app_name)   
    if application.valid?
      begin
        #application.elaborate
        application.save
        #Rails.logger.debug "Creating application #{app_name}"
        #application.create
        #Rails.logger.debug "Configuring dependencies #{app_name}"
        #application.configure_dependencies
        #Rails.logger.debug "Adding system ssh keys #{app_name}"
        #application.add_system_ssh_keys
        #Rails.logger.debug "Adding ssh keys #{app_name}"
        #application.add_ssh_keys
        #Rails.logger.debug "Adding system environment vars #{app_name}"
        #application.add_system_env_vars
        begin
          Rails.logger.debug "Creating dns"
          #application.create_dns
        rescue Exception => e
            #application.destroy_dns
            @reply = RestReply.new(:internal_server_error)
            message = Message.new(:error, "Failed to create dns for application #{app_name}") 
            @reply.messages.push(message)
            message = Message.new(:error, e.message) 
            @reply.messages.push(message)
            respond_with @reply, :status => @reply.status
            return
        end
      rescue Exception => e
        Rails.logger.error e.inspect
        if application.persisted?
          Rails.logger.debug e.message
          Rails.logger.debug e.backtrace.inspect
          #application.deconfigure_dependencies
          #application.destroy
          application.delete
        end

        @reply = RestReply.new(:internal_server_error)
        message = Message.new(:error, "Failed to create application #{app_name}") 
        @reply.messages.push(message)
        message = Message.new(:error, e.message) 
        @reply.messages.push(message)
        respond_with @reply, :status => @reply.status
        return
      end
      app = RestApplication.new(application, domain_id)
      @reply = RestReply.new( :created, "application", app)
      message = Message.new(:info, "Application #{app_name} was created.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
    else
      @reply = RestReply.new(:bad_request)
      message = Message.new(:error, "Failed to create application #{app_name}") 
      @reply.messages.push(message)
      message = Message.new(:error, application.errors.first[1][:message]) 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
    end
  end
  
  # DELELTE domains/[domain_id]/applications/[id]
  def destroy
    domain_id = params[:domain_id]
    id = params[:id]
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if application.nil?
      @reply = RestReply.new(:not_found)
      message = Message.new(:error, "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    
    begin
      Rails.logger.debug "Deleting application #{id}"
      application.cleanup_and_delete()
    rescue Exception => e
      Rails.logger.error "Failed to Delete application #{id}: #{e.message}"
      @reply = RestReply.new(:internal_server_error)
      message = Message.new(:error, "Failed to delete application #{app_name}") 
      @reply.messages.push(message)
      message = Message.new(:error, e.message) 
      @reply.messages.push(message)
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
 
    @reply = RestReply.new(:no_content)
    message = Message.new(:info, "Application #{id} is deleted.")
    @reply.messages.push(message)
    respond_with(@reply) do |format|
      format.xml { render :xml => @reply, :status => @reply.status }
      format.json { render :json => @reply, :status => @reply.status }
    end
  end
end
