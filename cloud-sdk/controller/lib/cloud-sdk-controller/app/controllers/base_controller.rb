class BaseController < ActionController::Base
  respond_to :json, :xml
    
  def show
    links = [
      Link.new("API entry point", "GET", "/api"),
      Link.new("Get user information", "GET", "/user"),      
      Link.new("List domains", "GET", "/domains"),
      Link.new("Create new domain", "POST", "/domains", [
        Param.new("namespace", "string", "Name of the domain"),
        Param.new("ssh", "string", "The key portion of an rsa key (excluding ssh-rsa and comment)")
      ]),
      Link.new("List cartridges", "GET", "/cartridges"),
      Link.new("List standalone cartridges", "GET", "/cartridges/standalone"),
      Link.new("List embedded cartridges", "GET", "/cartridges/embedded"),
    ]
    
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