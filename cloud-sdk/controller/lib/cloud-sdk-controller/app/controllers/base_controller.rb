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
      "LIST_TEMPLATES" => Link.new("List application templates", "GET", "/application_template")
    }
    
    @reply = RestReply.new(:ok, "links", links)
    respond_with @reply, :status => @reply.status
  end
  
  protected
  
  def authenticate
    login = nil
    password = nil
    authenticate_with_http_basic { |u, p|
      login = u
      password = p
    }
    auth = Cloud::Sdk::AuthService.instance.authenticate(request, login, password)
    if auth
      @login = auth[:username]
      @auth_method = auth[:auth_method]      
    else
      request_http_basic_authentication
    end
    
    @cloud_user = CloudUser.find @login
    @cloud_user.auth_method = @auth_method unless @cloud_user.nil?
  end
  
  def rest_replies_url(*args)
    return "/broker/rest/api"
  end
end
