class BaseController < ActionController::Base
  respond_to :json, :xml
    
  def show
    links = {
      "API" => Link.new("API entry point", "GET", "/api"),
      "GET_USER" => Link.new("Get user information", "GET", "/user"),      
      "LIST_DOMAINS" => Link.new("List domains", "GET", "/domains"),
      "ADD_DOMAIN" => Link.new("Create new domain", "POST", "/domains", [
        Param.new("namespace", "string", "Name of the domain")
      ]),
      "LIST_CARTRIDGES" => Link.new("List cartridges", "GET", "/cartridges"),
      "LIST_TEMPLATES" => Link.new("List application templates", "GET", "/application_template"),
      "GET_ESTIMATES" => Link.new("List available estimates", "GET" , "/estimates")
    }
    
    @reply = RestReply.new(:ok, "links", links)
    respond_with @reply, :status => @reply.status
  end
  
  protected
  
  def authenticate
    login = nil
    password = nil
    if request.headers['User-Agent'] == "StickShift"
      if params['broker_auth_key'] && params['broker_auth_iv']
        login = params['broker_auth_key']
        password = params['broker_auth_iv']
      end
    end
    if login.nil? or password.nil?
      authenticate_with_http_basic { |u, p|
        login = u
        password = p
      }
    end
    begin
      auth = StickShift::AuthService.instance.authenticate(request, login, password)
      @login = auth[:username]
      @auth_method = auth[:auth_method]      

      Rails.logger.debug "Adding user #{@login}...inside base_controller"
      @cloud_user = CloudUser.find @login
      if @cloud_user.nil?
        @cloud_user = CloudUser.new(@login)
        @cloud_user.save
      end
      @cloud_user.auth_method = @auth_method unless @cloud_user.nil?
    rescue StickShift::AccessDeniedException
      request_http_basic_authentication
    end
  end
  
  def rest_replies_url(*args)
    return "/broker/rest/api"
  end
end
