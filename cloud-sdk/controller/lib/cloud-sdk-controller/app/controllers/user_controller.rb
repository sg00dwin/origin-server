class UserController < BaseController
  respond_to :json, :xml
  before_filter :authenticate
  
  # GET /user
  def show
    user = CloudUser.find(@login)
    links = [
      Link.new("API entry point", "GET", "/api"),
      Link.new("Get user information", "GET", "/user"),
      Link.new("List domains", "GET", "/domains")
    ]
    
    if(user.nil?)
      @reply = RestReply.new(:not_found, links)
      @reply.messages.push(Message.new(:error, "User information for #{@login} not available."))
      respond_with @result, :status => @reply.status
    end
    
    @reply = RestReply.new(:ok, links, "user", RestUser.new(user))
    respond_with @reply, :status => @reply.status
  end
end
