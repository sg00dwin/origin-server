class ApplicationsController < BaseController
  respond_to :html, :xml, :json
  before_filter :authenticate
  
  
  # GET /applications
  def index
    cloud_user = CloudUser.find(@login)
    applications = Application.find_all(cloud_user)
    if applications.nil? 
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "No applications found for user #{@login}.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
    end
    apps = Array.new
    applications.each do |application|
      app = RestApplication.new(application)
      app.links = get_links(app)
      apps.push(app)
    end
    @reply = RestReply.new(:ok, "application", apps)
    respond_with @reply, :status => @reply.status
  end
  
  # GET /applications/<id>
  def show
    id = params[:id]
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if(application.nil?)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
    end
    #application.links = get_links(application)
    @reply = RestReply.new(:ok, "application", application)
    respond_with @reply, :status => @reply.status
  end
  
  # POST /applications
  def create
    user = CloudUser.find(@login)
    app_name = params[:name]
    if Cloud::Sdk::ApplicationContainerProxy.blacklisted? app_name
      @reply = RestReply.new(:forbidden)
      message = Message.new("ERROR", "The supplied application name '#{app_name}' is not allowed") 
      @reply.messages.push(message)
      respond_with(@reply, :status => :forbidden)
    end
    
    cartridge = params[:cartridge]
    if not check_cartridge_type(app.framework, container, "standalone")
      @reply = RestReply.new( :bad_request)
      carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("standalone")}
      message = Message.new("ERROR", "Invalid cartridge #{cartridge}.  Valid values are (#{carts.join(', ')})") 
      @reply.messages.push(message)
      respond_with(@reply, :status => :bad_request)  
    end
    
    app = Application.new(user, app_name, nil, nil, cartridge)
    container = Cloud::Sdk::ApplicationContainerProxy.find_available(nil)
    
    
    if (apps.length >= Rails.application.config.cdk[:per_user_app_limit])
      @reply = RestReply.new(:forbidden)
      message = Message.new("ERROR", "#{@login} has already reached the application limit of #{Rails.application.config.cdk[:per_user_app_limit]}")
      @reply.messages.push(message)
      respond_with(@reply, :status => :forbidden)
    end
    
        
    if app.valid?
      begin
        app.create(container)
        app.configure_dependencies
        app.add_system_ssh_keys
        app.add_secondary_ssh_keys
        app.add_system_env_vars
        begin
          app.create_dns
        rescue Exception => e
            app.destroy_dns
            @reply = RestReply.new(:internal_server_error)
            message = Message.new("ERROR", e.message) 
            @reply.messages.push(message)
            respond_with(@reply, :status => :internal_server_error)
        end
      rescue Exception => e
        if app.persisted?
          Rails.logger.debug e.message
          Rails.logger.debug e.backtrace.inspect
          app.deconfigure_dependencies
          app.destroy
          app.delete
        end

        @reply = RestReply.new(:internal_server_error)
        message = Message.new("ERROR", "Failed to create application #{app_name}") 
        @reply.messages.push(message)
        message = Message.new("ERROR", e.message) 
        @reply.messages.push(message)
        respond_with(@reply, :status => :internal_server_error)  
      end
        app.links = get_links(app)
        @reply = RestReply.new( :created, "application", application)
        message = Message.new("INFO", "Application #{app_name} was created.")
        @reply.messages.push(message)
        respond_with(@reply, :status =>  :created)
      else
        @reply = RestReply.new( :bad_request)
        message = Message.new("ERROR", "Failed to create application #{app_name}") 
        @reply.messages.push(message)
        message = Message.new("ERROR", app.errors.first[1][:message]) 
        @reply.messages.push(message)
        respond_with(@reply, :status => :bad_request)  
      end
  end
  
  # PUT /applications/<id>/<state>
  def update
    id = params[:id]
    state = params[:state]
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if(application.nil?)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with(@reply, :status => :not_found)
    end
    case state
      when "start"
        application.start
      when "stop"
        application.stop  
      when "force-stop"
        application.force_stop  
      when "restart"
        application.restart  
    end
    
    application = Application.find(cloud_user, id)
    application.links = get_links(application)
    @reply = RestReply.new(:ok, "application", application)
    respond_with(@reply, :status => :ok)
  end
  
  # POST /applications/<id>/cartridges
  def add_cartridge
    id = params[:id]
    cartridge = params[:cartridge]
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if(application.nil?)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with(@reply, :status => :not_found)
    end
    if not check_cartridge_type(app.framework, container, "embedded")
      @reply = RestReply.new( :bad_request)
      carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("embedded")}
      message = Message.new("ERROR", "Invalid cartridge #{cartridge}.  Valid values are (#{carts.join(', ')})") 
      @reply.messages.push(message)
      respond_with(@reply, :status => :bad_request)  
    end

    app.add_dependency(@req.cartridge)
    application = Application.find(cloud_user,id)
    application.links = get_links(application)
    @reply = RestReply.new(:ok, "application", application)
    message = Message.new("INFO", "Added #{cartridge} to application #{id}")
    @reply.messages.push(message)
    respond_with(@reply, :status => :ok)
  end
  
  # DELETE /applications/<id>/cartridges
  def remove_cartridge
    id = params[:id]
    cartridge = params[:cartridge]
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if(application.nil?)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with(@reply, :status => :not_found)
    end
    
    if not check_cartridge_type(app.framework, container, "embedded")
      @reply = RestReply.new( :bad_request)
      carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("embedded")}
      message = Message.new("ERROR", "Invalid cartridge #{cartridge}.  Valid values are (#{carts.join(', ')})") 
      @reply.messages.push(message)
      respond_with(@reply, :status => :bad_request)  
    end

    app.remove_dependency(@req.cartridge)
    application = Application.find(cloud_user, id)
    application.links = get_links(application)
    @reply = RestReply.new(:ok, "application", application)
    message = Message.new("INFO", "Removed #{cartridge} from application #{id}")
    @reply.messages.push(message)
    respond_with(@reply, :status => :ok)
  end
  
  # PUT /applications/<id>/cartridges/<cartridge>/<state>
  def update_cartridge
    id = params[:id]
    cartridge = params[:cartridge]
    state = params[:state]
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if(application.nil?)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with(@reply, :status => :not_found)
    end
    if not check_cartridge_type(app.framework, container, "embedded")
      @reply = RestReply.new( :bad_request)
      carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("embedded")}
      message = Message.new("ERROR", "Invalid cartridge #{cartridge}.  Valid values are (#{carts.join(', ')})") 
      @reply.messages.push(message)
      respond_with(@reply, :status => :bad_request)  
    end

    case state
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
        message = Message.new("ERROR", "Invalid action #{state}")
        @reply.messages.push(message)
        respond_with(@reply, :status => :bad_request)       
    end
    
    application = Application.find(cloud_user, id)
    application.links = get_links(application)
    @reply = RestReply.new(:ok, "application", application)
    message = Message.new("INFO", "Successful #{state} on #{cartridge} for application #{id}")
    @reply.messages.push(message)
    respond_with(@reply, :status => :ok)
  end
  
  # DELELTE /applications/<id>
  def destroy
    id = params[:id]
    cloud_user = CloudUser.find(@login)
    application = Application.find(cloud_user,id)
    if(application.nil?)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
    end
    
    application.cleanup_and_delete()
 
    @reply = RestReply.new(:no_content)
    message = Message.new("INFO", "Application #{id} is deleted.")
    @reply.messages.push(message)
    respond_with @reply, :status => @reply.status
  end
  
  def get_links(domain_id, app)
    links = Array.new
    link = Link.new("Get application", "GET", "/domains/#{domain_id}/applications/#{app.name}")
    links.push(link)
    link = Link.new("Start application", "PUT", "/domains/#{domain_id}/applications/#{app.name}/start")
    links.push(link)
    link = Link.new("Stop application", "PUT", "/domains/#{domain_id}/applications/#{app.name}/stop")
    links.push(link)
    link = Link.new("Restart application", "PUT", "/domains/#{domain_id}/applications/#{app.name}/restart")
    links.push(link)
    link = Link.new("Force stop application", "PUT", "/domains/#{domain_id}/applications/#{app.name}/force-stop")
    links.push(link)
    link = Link.new("Delete application", "DELETE", "/domains/#{domain_id}/applications/#{app.name}")
    links.push(link)
    
    link = Link.new("Add embedded cartridge", "POST", "/domains/#{domain_id}/applications/#{app.name}/cartridges")
    cart_type = "embedded"
    cache_key = "cart_list_#{cart_type}"
    #carts = get_cached(cache_key, :expires_in => 21600.seconds) {
    #  Application.get_available_cartridges("embedded")}
    #param = Param.new("cartridge", "string", "framework-type, e.g.: mysql-5.1", carts.join(', '))
    #link.required_params.push(param)
    links.push(link)
    
    link = Link.new("Start embedded cartridge", "PUT", "/domains/#{domain_id}/applications/#{app.name}/cartridges/#{app.embedded}/start")
    links.push(link)
    link = Link.new("Stop embedded cartridge", "PUT", "/domains/#{domain_id}/applications/#{app.name}/cartridges/#{app.embedded}/stop")
    links.push(link)
    link = Link.new("Restart embedded cartridge", "PUT", "/domains/#{domain_id}/applications/#{app.name}/cartridges/#{app.embedded}/restart")
    links.push(link)
    link = Link.new("Reload embedded cartridge", "PUT", "/domains/#{domain_id}/applications/#{app.name}/cartridges/#{app.embedded}/reload")
    links.push(link)

    return links
  end
  
  def check_cartridge_type(framework, container, cart_type)
    carts = container.get_available_cartridges(cart_type)
    unless carts.include? framework
      return false
    end
    return true
  end
  
 
end
