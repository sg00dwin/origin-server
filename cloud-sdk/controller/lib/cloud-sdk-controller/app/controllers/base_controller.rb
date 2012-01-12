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
      Link.new("List standalone cartridges", "GET", "/cartridges"),
      Link.new("List embedded cartridges", "GET", "/cartridges/embedded"),
    ]
    
    @reply = RestReply.new(:ok, "links", links)
    respond_with @reply, :status => @reply.status
  end
  
  protected
  
  def authenticate
    #@login = Cloud::Sdk::AuthService.instance.login(request, params, cookies)
    #unless @login
    #  #TODO return 401
    #end
    @login = "lnader@redhat.com"
  end
end