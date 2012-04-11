class BaseController < ActionController::Base
  respond_to :json, :xml
  def show
    links = {
      "API" => Link.new("API entry point", "GET", URI::join(get_url, "api")),
      "GET_USER" => Link.new("Get user information", "GET", URI::join(get_url, "user")),      
      "LIST_DOMAINS" => Link.new("List domains", "GET", URI::join(get_url, "domains")),
      "ADD_DOMAIN" => Link.new("Create new domain", "POST", URI::join(get_url, "domains"), [
        Param.new("id", "string", "Name of the domain")
      ]),
      "LIST_CARTRIDGES" => Link.new("List cartridges", "GET", URI::join(get_url, "cartridges")),
      "LIST_TEMPLATES" => Link.new("List application templates", "GET", URI::join(get_url, "application_template")),
      "LIST_ESTIMATES" => Link.new("List available estimates", "GET" , URI::join(get_url, "estimates"))
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
  
  def get_url
    #Rails.logger.debug "Request URL: #{request.url}"
    url = URI::join(request.url, "/broker/rest/")
    #Rails.logger.debug "Request URL: #{url.to_s}"
    return url.to_s
  end
end
