class DomainsController < BaseController
  respond_to :html, :xml, :json
  before_filter :authenticate

  # GET /domains
  def index
    cloud_user = CloudUser.find(@login)
    if cloud_user.nil?
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "No domain found for user #{@login}.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
    end
    domain = Domain.new(cloud_user.namespace, cloud_user.ssh)
    @reply = RestReply.new(:ok, "domain", domain)
    respond_with @reply, :status => @reply.status
  end
  
  # GET /domains/<id>
  def show
    id = params[:id]
    cloud_user = CloudUser.find(@login)
    if(cloud_user.nil? or cloud_user.namespace != id)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Domain #{id} not found.")
      @reply.messages.push(message)
      respond_with @reply, :status => @reply.status
    end
    domain = Domain.new(cloud_user.namespace, cloud_user.ssh)
    @reply = RestReply.new(:ok, "domain", domain)
    respond_with @reply, :status => @reply.status
  end
  
  # POST /domains
  def create
    namespace = params[:namespace]
    ssh = params[:ssh]
    cloud_user = CloudUser.find(@login)
    
    if (cloud_user or Cloud::Sdk::ApplicationContainerProxy.blacklisted? namespace)
      @reply = RestReply.new(:conflict)
      message = Message.new("ERROR", "Domain not allowed.")
      @reply.messages.push(message)
      respond_with(@reply, :status => :conflict)
    end
    
    cloud_user = CloudUser.new(@login, ssh, namespace)
    cloud_user.save
    
    domain = Domain.new(cloud_user.namespace, cloud_user.ssh)
    @reply = RestReply.new(:created, "domain", domain)
    message = Message.new("INFO", "Domain was created.")
    @reply.messages.push(message)
    respond_with(@reply, :status => :created)
    
  end
  
  
  # PUT /domains/<id>
  def update
    cloud_user = CloudUser.find(@login)
    id = params[:id]
    new_namespace = params[:namespace]
    ssh = params[:ssh]
    
    if(cloud_user.nil? or cloud_user.namespace != id)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Domain not found.")
      @reply.messages.push(message)
      respond_with(@reply, :status => :not_found)
    end
    cloud_user.update_ssh(ssh)
    cloud_user.update_namespace(namespace)
    
    cloud_user = CloudUser.find(@login)
    domain = Domain.new(cloud_user.namespace, cloud_user.ssh)
    @reply = RestReply.new(:ok, "domain", domain)
    message = Message.new("INFO", "Domain was updated.")
    @reply.messages.push(message)
    respond_with(@reply, :status => :ok)
  end
  
  
  # DELELTE /domains/<id>
  def destroy
    cloud_user = CloudUser.find(@login)
    namespace = params[:id]
    force = params[:force]
    
    if(cloud_user.nil? or cloud_user.namespace != namespace)
      @reply = RestReply.new(:not_found)
      message = Message.new("ERROR", "Domain not found.")
      @reply.messages.push(message)
      respond_with(@reply, :status => :not_found)
    end
    if (!cloud_user.applications.empty? and !force)
      @reply = RestReply.new( :bad_request)
      message = Message.new("ERROR", "Domain contains applications.  
          Delete applications first or set force to true.")
      @reply.messages.push(message)
      respond_with(@reply, :status =>  :bad_request)
    elsif force
      cloud_user.applications.each do |app|
        app.cleanup_and_delete()
      end
    end
    cloud_user.delete
    
    @reply = RestReply.new(:no_content)
    message = Message.new("INFO", "Damain deleted.")
    @reply.messages.push(message)
    respond_with(@reply, :status => :no_content)
    
  end
  
  def get_links(id)
    links = Array.new
    link = Link.new("Get domain", "GET", "/domains/" + id)
    links.push(link)
    
    link = Link.new("List applications", "GET", "/domains/#{id}/applications")
    links.push(link)
        
    link = Link.new("Create new application", "POST", "/applications")
    param = Param.new("name", "string", "Name of the application")
    link.required_params.push(param)
    carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges("standalone")}
    param = Param.new("cartridge", "string", "framework-type, e.g: php-5.3", carts.join(', '))
    link.required_params.push(param)
    links.push(link)
       
    link = Link.new("Delete domain", "DELETE", "/domains/" + id)
    param = OptionalParam.new("force", "boolean", "Force delete domain.  i.e. delete any applications under this domain", "true or false", false)
    link.optional_params.push(param)
    links.push(link)

    return links
  end
end
