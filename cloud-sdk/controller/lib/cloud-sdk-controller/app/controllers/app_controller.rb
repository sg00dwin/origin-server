class AppController < BaseController
  respond_to :html, :xml, :json
  before_filter :authenticate
  
  
  # GET /applications
  def index
    applications = Application.find_all(@login)
    if(applications.nil?)
      @result = Result.new(:not_found)
      message = Message.new("ERROR", "No applications found.")
      @result.messages.push(message)
      respond_with(@result, :status => :not_found)
    end
    applications.each do |app|
      app.links = get_links(app.name)
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
    application.links = get_links(id)
    @result = Result.new(:ok, "application", application)
    respond_with(@result, :status => :ok)
  end
  
  # POST /applications
  def create
    user = CloudUser.find(@login)
    app_name = params[:name]
    cartridge = params[:cartridge]
    app = Application.new(user, app_name, nil, nil, cartridge)
    container = Cloud::Sdk::ApplicationContainerProxy.find_available(nil)
    check_cartridge_type(app.framework, container, "standalone")
    if (apps.length >= Rails.application.config.cdk[:per_user_app_limit])
      @result = Result.new(:forbidden)
      message = Message.new("ERROR", "#{@login} has already reached the application limit of #{Rails.application.config.cdk[:per_user_app_limit]}")
      result.messages.push(message)
      respond_with(@result, :status => :forbidden)
    end
    if Cloud::Sdk::ApplicationContainerProxy.blacklisted? app.name
      @result = Result.new(:forbidden)
      message = Message.new("ERROR", "The supplied application name '#{app.name}' is not allowed") 
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
            
          case app.framework_cartridge
            when 'php'
              page = 'health_check.php'
            when 'perl'
              page = 'health_check.pl'
            else
              page = 'health'
          end
          @reply.data = {:health_check_path => page, :uuid => app.uuid}.to_json
        rescue Exception => e
            app.destroy_dns
            @result = Result.new(:internal_server_error)
            message = Message.new("ERROR", e) 
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
        message = Message.new("ERROR", e) 
        result.messages.push(message)
        respond_with(@result, :status => :internal_server_error)  
      end
        app.links = get_links(id)
        @result = Result.new( :created, "application", application)
        message = Message.new("INFO", "Domain was created.")
        @result.messages.push(message)
        respond_with(@result, :status =>  :created)
      else
        @result = Result.new( :bad_request)
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
    application.links = get_links(id)
    @result = Result.new(:ok, "application", application)
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
  
  def get_links(id)
    links = Array.new
    link = Link.new("GET", "/applications/" + id)
    links.push(link)
    link = Link.new("PUT", "/applications/" + id + "/start")
    links.push(link)
    link = Link.new("PUT", "/applications/" + id + "/stop")
    links.push(link)
    link = Link.new("PUT", "/applications/" + id + "/restart")
    links.push(link)
    link = Link.new("PUT", "/applications/" + id + "/force-stop")
    links.push(link)
    link = Link.new("DELETE", "/applications/" + id)
    links.push(link)
    return links
  end
  
end
