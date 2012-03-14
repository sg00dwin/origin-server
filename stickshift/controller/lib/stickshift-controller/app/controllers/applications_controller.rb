class ApplicationsController < BaseController
  respond_to :xml, :json
  before_filter :authenticate
  include LegacyBrokerHelper
  
  # GET /domains/[domain id]/applications
  def index
    domain_id = params[:domain_id]
    
    applications = Application.find_all(@cloud_user)
    apps = Array.new
    if not applications.nil? 
      applications.each do |application|
        app = RestApplication.new(application, domain_id)
        apps.push(app)
      end
    end
    @reply = RestReply.new(:ok, "applications", apps)
    respond_with @reply, :status => @reply.status
  end
  
  # GET /domains/[domain_id]/applications/<id>
  def show
    domain_id = params[:domain_id]
    id = params[:id]
    
    application = Application.find(@cloud_user,id)
    
    if application.nil?
      @reply = RestReply.new(:not_found)
      message = Message.new(:error, "Application #{id} not found.", 101)
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
    
    app_name = params[:name]
    cartridge = params[:cartridge]
    scale = params[:scale]
    scale = false if scale.nil? or scale=="false"
    scale = true if scale=="true"
    optimize = params[:optimize]
    optimize = false if optimize.nil? or optimize=="false"
    optimize = true if optimize=="true"
    template_id = params[:template]

    if app_name.nil? or app_name.empty?
      @reply = RestReply.new(:unprocessable_entity)
      message = Message.new(:error, "Application name is required and cannot be blank", 105, "name") 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    application = Application.find(@cloud_user,app_name)
    if not application.nil?
      @reply = RestReply.new(:unprocessable_entity)
      message = Message.new(:error, "The supplied application name '#{app_name}' already exists", 100, "name") 
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    Rails.logger.debug "Checking to see if user limit for number of apps has been reached"
    if (@cloud_user.consumed_gears >= @cloud_user.max_gears)
      @reply = RestReply.new(:forbidden)
      message = Message.new(:error, "#{@login} has already reached the application limit of #{@cloud_user.max_gears}", 104)
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
      return
    end
    application = nil
    
    if not template_id.nil?
      template = ApplicationTemplate.find(params[:template])
      if template.nil?
        @reply = RestReply.new(:unprocessable_entity)
        message = Message.new(:error, "Invalid template #{params[:template]}.", 125, "template") 
        @reply.messages.push(message)
        respond_with @reply, :status => @reply.status
      end
      application = Application.new(@cloud_user, app_name, nil, nil, nil, template, scale)
    else
      if cartridge.nil? or not CartridgeCache.cartridge_names('standalone').include?(cartridge)
        @reply = RestReply.new(:unprocessable_entity)
        carts = get_cached("cart_list_standalone", :expires_in => 21600.seconds) {Application.get_available_cartridges("standalone")}
        message = Message.new(:error, "Invalid cartridge #{cartridge}.  Valid values are (#{carts.join(', ')})", 109, "cartridge") 
        @reply.messages.push(message)
        respond_with @reply, :status => @reply.status
        return
      end
      application = Application.new(@cloud_user, app_name, nil, nil, cartridge, nil, scale)
    end

    application.optimize = optimize
        
    Rails.logger.debug "Validating application"  
    if application.valid?
      begin
        Rails.logger.debug "Creating application #{application.name}"
        application.create
        Rails.logger.debug "Configuring dependencies #{application.name}"
        application.configure_dependencies
        Rails.logger.debug "Adding system ssh keys #{application.name}"
        application.add_system_ssh_keys
        Rails.logger.debug "Adding ssh keys #{application.name}"
        application.add_ssh_keys
        Rails.logger.debug "Adding system environment vars #{application.name}"
        application.add_system_env_vars
        Rails.logger.debug "Executing connections for #{application.name}"
        application.execute_connections
        begin
          Rails.logger.debug "Creating dns"
          application.create_dns
        rescue Exception => e
            Rails.logger.error e
            application.destroy_dns
            @reply = RestReply.new(:internal_server_error)
            message = Message.new(:error, "Failed to create dns for application #{application.name} due to:#{e.message}", e.code) 
            @reply.messages.push(message)
            message = Message.new(:error, "Failed to create application #{application.name} due to DNS failure.", e.code) 
            @reply.messages.push(message)
            application.deconfigure_dependencies
            application.destroy
            application.delete
            respond_with @reply, :status => @reply.status
            return
        end
      rescue Exception => e
        if application.persisted?
          Rails.logger.debug e.message
          Rails.logger.debug e.backtrace.inspect
          application.deconfigure_dependencies
          application.destroy
          application.delete
        end
    
        @reply = RestReply.new(:internal_server_error)
        message = Message.new(:error, "Failed to create application #{application.name} due to:#{e.message}", e.code) 
        @reply.messages.push(message)
        respond_with @reply, :status => @reply.status
        return
      end
      application.stop
      application.start
      
      app = RestApplication.new(application, domain_id)
      @reply = RestReply.new( :created, "application", app)
      message = Message.new(:info, "Application #{application.name} was created.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
    else
      @reply = RestReply.new(:unprocessable_entity)
      application.errors.keys.each do |key|
        error_messages = application.errors.get(key)
        error_messages.each do |error_message|
          @reply.messages.push(Message.new(:error, error_message[:message], error_message[:exit_code], key))
        end
      end
      respond_with @reply, :status => @reply.status
    end
  end
  
  # DELELTE domains/[domain_id]/applications/[id]
  def destroy
    domain_id = params[:domain_id]
    id = params[:id]
    
    application = Application.find(@cloud_user,id)
    if application.nil?
      @reply = RestReply.new(:not_found)
      message = Message.new(:error, "Application #{id} not found.", 101)
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
      message = Message.new(:error, "Failed to delete application #{app_name} due to:#{e.message}", e.code) 
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
