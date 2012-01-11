class BaseController < ActionController::Base
  respond_to :html, :xml, :json
  
  def authenticate
    @login = Cloud::Sdk::BasicAuthService.instance.login(request, params, cookies)
    unless @login
      #TODO return 401
    end
  end
  
  def index
    links = Array.new
    link = Link.new("GET", "/applications")
    links.push(link)
    link = Link.new("GET", "/cartridges")
    links.push(link)
    link = Link.new("GET", "/domains")
    links.push(link)
    link = Link.new("GET", "/users")
    links.push(link)
    @result = Result.new(:ok, "links", links)
    respond_with(@result, :status => :ok)
  end
end