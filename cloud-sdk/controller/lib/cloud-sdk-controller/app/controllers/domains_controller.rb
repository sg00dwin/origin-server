class DomainsController < BaseController
  respond_to :xml, :json
  before_filter :authenticate, :validate_params
  before_filter :lookup_user, :except => [:create]
  
  NAMESPACE_MAX_LENGTH = 16

  # GET /domains
  def index
    domain = RestDomain.new(@cloud_user.namespace)
    @reply = RestReply.new(:ok, "domains", [domain])
    respond_with @reply, :status => @reply.status
  end
  
  # GET /domains/<id>
  def show
    id = params[:id]
    if(@cloud_user.namespace != id)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(message = Message.new(:error, "Domain #{id} not found."))
      respond_with @reply, :status => @reply.status
      return
    end
    domain = RestDomain.new(@cloud_user.namespace)
    @reply = RestReply.new(:ok, "domain", domain)
    respond_with @reply, :status => @reply.status
  end
  
  # POST /domains
  def create
    namespace = params[:namespace]
    ssh = params[:ssh]
    Rails.logger.debug "Creating domain with namespace #{namespace}"
    cloud_user = CloudUser.find(@login)
    
    if cloud_user
      @reply = RestReply.new(:conflict)
      @reply.messages.push(Message.new(:error, "User already has a domain associated. Update the domain to modify."))
      respond_with @reply, :status => @reply.status
      return
    end
    
    cloud_user = CloudUser.new(@login, ssh, namespace)
    if cloud_user.invalid?
      @reply = RestReply.new(:unprocessable_entity)
      cloud_user.errors.each do |key, message|
        @reply.messages.push(Message.new(:error, message))
      end
      respond_with @reply, :status => @reply.status
      return
    end
    
    begin
      result_io = cloud_user.save
    rescue Cloud::Sdk::UserException => e
      @reply = RestReply.new(:conflict)
      @reply.process_result_io(e.resultIO)
      @reply.messages.push(e.message)
      respond_with @reply, :status => @reply.status
      return
    rescue Cloud::Sdk::DNSException => e
      @reply = RestReply.new(:conflict)
      @reply.process_result_io(e.resultIO)
      @reply.messages.push(e.message)
      respond_with @reply, :status => @reply.status
      return
    end
    
    domain = RestDomain.new(cloud_user.namespace)
    @reply = RestReply.new(:created, "domain", domain)
    @reply.process_result_io(result_io)
    respond_with @reply, :status => @reply.status
  end
  
  
  # PUT /domains/<id>
  def update
    id = params[:id]
    new_namespace = params[:namespace]
    ssh = params[:ssh]
    key_type = params[:key_type] || "rsa"
    
    if @cloud_user.namespace != id
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "Domain #{id} not found."))
      respond_with @reply, :status => @reply.status
      return
    end
    
    result_io = ResultIO.new
    result_io.append @cloud_user.update_ssh_key(ssh, key_type) unless params[:ssh].nil?
    result_io.append @cloud_user.update_namespace(new_namespace) unless params[:namespace].nil?
    
    domain = RestDomain.new(@cloud_user.namespace)
    @reply = RestReply.new(:ok, "domain", domain)
    @reply.process_result_io(result_io)
    respond_with @reply, :status => @reply.status
  end
  
  
  # DELETE /domains/<id>
  def destroy
    id = params[:id]
    force = params[:force]

    if(@cloud_user.namespace != id)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "Domain #{id} not found."))
      #respond_with @reply, :status => @reply.status
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    
    result_io = ResultIO.new
    if (!@cloud_user.applications.empty? and !force)
      @reply = RestReply.new(:bad_request)
      @reply.messages.push(Message.new(:error, "Domain contains applications. Delete applications first or set force to true."))
      #respond_with @reply, :status => @reply.status
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    elsif force
      @cloud_user.applications.each do |app|
        result_io.append app.cleanup_and_delete()
      end
    end
    
    @reply = RestReply.new(:no_content)
    result_io.append @cloud_user.delete
    @reply.process_result_io(result_io)
    @reply.messages.push(Message.new(:info, "Damain deleted."))
    #respond_with @reply, :status => @reply.status
    respond_with(@reply) do |format|
       format.xml { render :xml => @reply, :status => @reply.status }
       format.json { render :json => @reply, :status => @reply.status }
    end
  end
  
  protected
  
  def validate_params
    errors = []
    
    unless params[:namespace].nil? and params[:id].nil?
      val = params[:namespace] || params[:id]
      if !(val =~ /\A[A-Za-z0-9]+\z/)
        errors.push({:message => "Invalid namespace: #{val}", :exit_code => 106})
      end
      if val and val.length > NAMESPACE_MAX_LENGTH
        errors.push({:message => "Namespace (#{val}) is not available for use.  Please choose another.", :exit_code => 106})
      end
      if Cloud::Sdk::ApplicationContainerProxy.blacklisted? val
        error.push({:message => "Namespace (#{val}) is not allowed.  Please choose another.", :exit_code => 106})
      end
    end
    
    unless params[:ssh].nil?
      val = params[:ssh]
      unless (val =~ /\A[A-Za-z0-9\+\/=]+\z/)
        errors.push({:message => "Invalid ssh key: #{val}", :exit_code => 108})
      end
    end
    
    unless errors.empty?
      @reply = RestReply.new(:bad_request)
      errors.each do |msg|
        @reply.messages.push(Message.new(:error, msg))
      end
      respond_with @reply, :status => @reply.status
      return
    end
  end
  
  def lookup_user
    @cloud_user = CloudUser.find(@login)
    if @cloud_user.nil?
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "User #{@login} not found"))
      respond_with @reply, :status => @reply.status
      return
    end
  end
end
