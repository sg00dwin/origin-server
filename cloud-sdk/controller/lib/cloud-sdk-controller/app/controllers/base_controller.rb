class BaseController < ActionController::Base
  respond_to :json, :xml
  
  def authenticate
    @login = Cloud::Sdk::AuthService.instance.login(request, params, cookies)
    unless @login
      #TODO return 401
    end
  end
  
  def show
    links = [
      Link.new("List domains", "GET", "/domains"),
      Link.new("Create new domain", "POST", "/domains", [
        Param.new("namespace", "string", "Name of the domain"),
        Param.new("ssh", "string", "The key portion of an rsa key (excluding ssh-rsa and comment)")
      ]),
      Link.new("List standalone cartridges", "GET", "/cartridges"),
      Link.new("List embedded cartridges", "GET", "/cartridges/embedded"),
      Link.new("List users", "GET", "/users")
    ]
    
    @reply = RestReply.new(:ok, "links", links)
    respond_with @reply, :status => @reply.status
  end
end