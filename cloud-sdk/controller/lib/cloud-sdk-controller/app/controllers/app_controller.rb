class AppController < BaseController
  respond_to :html, :xml, :json
  before_filter :authenticate
  
  
  # GET /applications
  def index
    applications = Application.find_all(@login)
    if(applications.nil?)
      @result = Result.new(:not_found)
      message = Message.new("ERROR", "No applications found for user #{@login}.")
      @result.messages.push(message)
      respond_with(@result, :status => :not_found)
    end
    applications.each do |app|
      app.links = get_links(app)
    end
    @result = Result.new(:ok, "applications", applications)
    respond_with(@result, :status => :ok)
  end
  
  # GET /applications/<id>
  def show
    id = params[:id]
    application = Application.find(@login,id)
    if(application.nil?)
      @result = Result.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @result.messages.push(message)
      respond_with(@result, :status => :not_found)
    end
    application.links = get_links(application)
    @result = Result.new(:ok, "application", application)
    respond_with(@result, :status => :ok)
  end
  
  # POST /applications
  def create
    user = CloudUser.find(@login)
    app_name = params[:name]
    if Cloud::Sdk::ApplicationContainerProxy.blacklisted? app_name
      @result = Result.new(:forbidden)
      message = Message.new("ERROR", "The supplied application name '#{app_name}' is not allowed") 
      result.messages.push(message)
      respond_with(@result, :status => :forbidden)
    end
    
    cartridge = params[:cartridge]
    if not check_cartridge_type(app.framework, container, "standalone")
      @result = Result.new( :bad_request)
      carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("standalone")}
      message = Message.new("ERROR", "Invalid cartridge #{cartridge}.  Valid values are (#{carts.join(', ')})") 
      @result.messages.push(message)
      respond_with(@result, :status => :bad_request)  
    end
    
    app = Application.new(user, app_name, nil, nil, cartridge)
    container = Cloud::Sdk::ApplicationContainerProxy.find_available(nil)
    
    
    if (apps.length >= Rails.application.config.cdk[:per_user_app_limit])
      @result = Result.new(:forbidden)
      message = Message.new("ERROR", "#{@login} has already reached the application limit of #{Rails.application.config.cdk[:per_user_app_limit]}")
      result.messages.push(message)
      respond_with(@result, :status => :forbidden)
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
            @result = Result.new(:internal_server_error)
            message = Message.new("ERROR", e.message) 
            result.messages.push(message)
            respond_with(@result, :status => :internal_server_error)
        end
      rescue Exception => e
        if app.persisted?
          Rails.logger.debug e.message
          Rails.logger.debug e.backtrace.inspect
          app.deconfigure_dependencies
          app.destroy
          app.delete
        end

        @result = Result.new(:internal_server_error)
        message = Message.new("ERROR", "Failed to create application #{app_name}") 
        result.messages.push(message)
        message = Message.new("ERROR", e.message) 
        result.messages.push(message)
        respond_with(@result, :status => :internal_server_error)  
      end
        app.links = get_links(app)
        @result = Result.new( :created, "application", application)
        message = Message.new("INFO", "Application #{app_name} was created.")
        @result.messages.push(message)
        respond_with(@result, :status =>  :created)
      else
        @result = Result.new( :bad_request)
        message = Message.new("ERROR", "Failed to create application #{app_name}") 
        result.messages.push(message)
        message = Message.new("ERROR", app.errors.first[1][:message]) 
        @result.messages.push(message)
        respond_with(@result, :status => :bad_request)  
      end
  end
  
  # PUT /applications/<id>/<state>
  def update
    id = params[:id]
    state = params[:state]
    application = Application.find(@login,id)
    if(application.nil?)
      @result = Result.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @result.messages.push(message)
      respond_with(@result, :status => :not_found)
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
    
    application = Application.find(@login,id)
    application.links = get_links(application)
    @result = Result.new(:ok, "application", application)
    respond_with(@result, :status => :ok)
  end
  
  # POST /applications/<id>/cartridges
  def add_cartridge
    id = params[:id]
    cartridge = params[:cartridge]
    application = Application.find(@login,id)
    if(application.nil?)
      @result = Result.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @result.messages.push(message)
      respond_with(@result, :status => :not_found)
    end
    if not check_cartridge_type(app.framework, container, "embedded")
      @result = Result.new( :bad_request)
      carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("embedded")}
      message = Message.new("ERROR", "Invalid cartridge #{cartridge}.  Valid values are (#{carts.join(', ')})") 
      @result.messages.push(message)
      respond_with(@result, :status => :bad_request)  
    end

    app.add_dependency(@req.cartridge)
    application = Application.find(@login,id)
    application.links = get_links(application)
    @result = Result.new(:ok, "application", application)
    message = Message.new("INFO", "Added #{cartridge} to application #{id}")
    @result.messages.push(message)
    respond_with(@result, :status => :ok)
  end
  
  # DELETE /applications/<id>/cartridges
  def remove_cartridge
    id = params[:id]
    cartridge = params[:cartridge]
    application = Application.find(@login,id)
    if(application.nil?)
      @result = Result.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @result.messages.push(message)
      respond_with(@result, :status => :not_found)
    end
    
    if not check_cartridge_type(app.framework, container, "embedded")
      @result = Result.new( :bad_request)
      carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("embedded")}
      message = Message.new("ERROR", "Invalid cartridge #{cartridge}.  Valid values are (#{carts.join(', ')})") 
      @result.messages.push(message)
      respond_with(@result, :status => :bad_request)  
    end

    app.remove_dependency(@req.cartridge)
    application = Application.find(@login,id)
    application.links = get_links(application)
    @result = Result.new(:ok, "application", application)
    message = Message.new("INFO", "Removed #{cartridge} from application #{id}")
    @result.messages.push(message)
    respond_with(@result, :status => :ok)
  end
  
  # PUT /applications/<id>/cartridges/<cartridge>/<state>
  def update_cartridge
    id = params[:id]
    cartridge = params[:cartridge]
    state = params[:state]
    application = Application.find(@login,id)
    if(application.nil?)
      @result = Result.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @result.messages.push(message)
      respond_with(@result, :status => :not_found)
    end
    if not check_cartridge_type(app.framework, container, "embedded")
      @result = Result.new( :bad_request)
      carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("embedded")}
      message = Message.new("ERROR", "Invalid cartridge #{cartridge}.  Valid values are (#{carts.join(', ')})") 
      @result.messages.push(message)
      respond_with(@result, :status => :bad_request)  
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
        @result = Result.new(:bad_request)
        message = Message.new("ERROR", "Invalid action #{state}")
        @result.messages.push(message)
        respond_with(@result, :status => :bad_request)       
    end
    
    application = Application.find(@login,id)
    application.links = get_links(application)
    @result = Result.new(:ok, "application", application)
    message = Message.new("INFO", "Successful #{state} on #{cartridge} for application #{id}")
    @result.messages.push(message)
    respond_with(@result, :status => :ok)
  end
  
  # DELELTE /applications/<id>
  def destroy
    id = params[:id]
    application = Application.find(@login,id)
    if(application.nil?)
      @result = Result.new(:not_found)
      message = Message.new("ERROR", "Application #{id} not found.")
      @result.messages.push(message)
      respond_with(@result, :status => :not_found)
    end
    
    application.cleanup_and_delete()
 
    @result = Result.new(:no_content)
    message = Message.new("INFO", "Application #{id} is deleted.")
    @result.messages.push(message)
    respond_with(@result, :status => :no_content)
  end
  
  def get_links(app)
    links = Array.new
    link = Link.new("GET", "/applications/#{app.name}")
    links.push(link)
    link = Link.new("PUT", "/applications/#{app.name}/start")
    links.push(link)
    link = Link.new("PUT", "/applications/#{app.name}/stop")
    links.push(link)
    link = Link.new("PUT", "/applications/#{app.name}/restart")
    links.push(link)
    link = Link.new("PUT", "/applications/#{app.name}/force-stop")
    links.push(link)
    link = Link.new("DELETE", "/applications/#{app.name}")
    links.push(link)
    
    link = Link.new("POST", "/applications/#{app.name}/cartridges")
    carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("embedded")}
    param = Param.new("cartridge", "string", "framework-type, e.g.: mysql-5.1", carts.join(', '))
    link.required_params.push(param)
    links.push(link)
    
    link = Link.new("PUT", "/applications/#{app.name}/cartridges/#{app.embedded}/start")
    links.push(link)
    link = Link.new("PUT", "/applications/#{app.name}/cartridges/#{app.embedded}/stop")
    links.push(link)
    link = Link.new("PUT", "/applications/#{app.name}/cartridges/#{app.embedded}/restart")
    links.push(link)
    link = Link.new("PUT", "/applications/#{app.name}/cartridges/#{app.embedded}/reload")
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
