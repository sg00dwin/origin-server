class BaseController < ActionController::Base
  respond_to :json, :xml
    
  def show
    links = {
      "API" => Link.new("API entry point", "GET", "/api"),
      "GET_USER" => Link.new("Get user information", "GET", "/user"),      
      "LIST_DOMAINS" => Link.new("List domains", "GET", "/domains"),
      "ADD_DOMAIN" => Link.new("Create new domain", "POST", "/domains", [
        Param.new("namespace", "string", "Name of the domain"),
        Param.new("ssh", "string", "The key portion of an rsa key (excluding ssh-rsa and comment)")
      ]),
      "LIST_CARTRIDGES" => Link.new("List cartridges", "GET", "/cartridges")
    }
    
    @reply = RestReply.new(:ok, "links", links)
    respond_with @reply, :status => @reply.status
  end
  
  protected
  
  def authenticate
    if user = authenticate_with_http_basic {|u, p| Cloud::Sdk::AuthService.instance.authenticate(request, u, p)}
      @login = user
    else
      request_http_basic_authentication
    end
  end
  
  def rest_replies_url(*args)
    return "/broker/rest/api"
  end
end