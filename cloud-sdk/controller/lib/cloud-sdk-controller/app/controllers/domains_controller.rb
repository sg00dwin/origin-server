class DomainsController < BaseController
  respond_to :xml, :json
  before_filter :authenticate
  before_filter :lookup_user, :except => [:create]
  before_filter :validate_params, :except => [:index, :show, :destroy]

  NAMESPACE_MAX_LENGTH = 16
  # GET /domains
  def index
    domains = Array.new
    if @cloud_user
      domain = RestDomain.new(@cloud_user.namespace)
    domains.push(domain)
    end
    @reply = RestReply.new(:ok, "domains", domains)
    respond_with @reply, :status => @reply.status
  end

  # GET /domains/<id>
  def show
    id = params[:id]
    if not @cloud_user or @cloud_user.namespace != id
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
    Rails.logger.debug "Creating domain with namespace #{namespace}"
    domain = Domain.new(namespace)
    if domain.invalid?
      @reply = RestReply.new(:unprocessable_entity)
      domain.errors.each do |attribute, message, exit_code|
        @reply.messages.push(Message.new(:error, message, exit_code, attribute))
      end
      respond_with @reply, :status => @reply.status
    end
    
    cloud_user = CloudUser.find(@login)

    if cloud_user
      @reply = RestReply.new(:conflict)
      @reply.messages.push(Message.new(:error, "User already has a domain associated. Update the domain to modify."))
      respond_with @reply, :status => @reply.status
    return
    end
    Rails.logger.debug "Validating user"
    cloud_user = CloudUser.new(@login, nil, namespace)
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
    Rails.logger.debug "Updating domain #{@cloud_user.namespace} to #{new_namespace}"
    if not @cloud_user or @cloud_user.namespace != id
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "Domain #{id} not found."))
      respond_with @reply, :status => @reply.status
    return
    end

    result_io = ResultIO.new
    result_io.append @cloud_user.update_namespace(new_namespace) unless params[:namespace].nil?
    @cloud_user = CloudUser.find(@login)
    domain = RestDomain.new(@cloud_user.namespace)
    @reply = RestReply.new(:ok, "domain", domain)
    @reply.process_result_io(result_io)
    #respond_with @reply, :status => @reply.status

    respond_with(@reply) do |format|
      format.xml { render :xml => @reply, :status => @reply.status }
      format.json { render :json => @reply, :status => @reply.status }
    end
  end

  # DELETE /domains/<id>
  def destroy
    id = params[:id]
    force_str = params[:force]
    if not force_str.nil? and force_str.upcase == "TRUE"
    force = true
    else
    force = false
    end

    if not @cloud_user or @cloud_user.namespace != id
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
    if force
      Rails.logger.debug "Force deleting domain #{id}"
      @cloud_user.applications.each do |app|
        result_io.append app.cleanup_and_delete()
      end
    elsif not @cloud_user.applications.empty?
      @reply = RestReply.new(:bad_request)
      @reply.messages.push(Message.new(:error, "Domain contains applications. Delete applications first or set force to true."))
      #respond_with @reply, :status => @reply.status
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
    return
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
    val = params[:namespace]
    if !(val =~ /\A[A-Za-z0-9]+\z/)
      errors.push({:message => "Invalid namespace: #{val}", :exit_code => 106})
    end
    if val and val.length > NAMESPACE_MAX_LENGTH
      errors.push({:message => "Namespace (#{val}) is too long.  Maximum length is #{NAMESPACE_MAX_LENGTH} characters", :exit_code => 106})
    end
    if Cloud::Sdk::ApplicationContainerProxy.blacklisted? val
      error.push({:message => "Namespace (#{val}) is not allowed.  Please choose another.", :exit_code => 106})
    end

    unless errors.empty?
      @reply = RestReply.new(:unprocessable_entity)
      errors.each do |msg|
        @reply.messages.push(Message.new(:error, msg))
      end
      respond_with @reply, :status => @reply.status
    return
    end
  end

  def lookup_user
    @cloud_user = CloudUser.find(@login)
  end
end
