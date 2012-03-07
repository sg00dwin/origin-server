class DomainsController < BaseController
  respond_to :xml, :json
  before_filter :authenticate

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
      @reply.messages.push(message = Message.new(:error, "Domain #{id} not found.", 127))
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
      domain.errors.keys.each do |key|
        error_messages = domain.errors.get(key)
        error_messages.each do |error_message|
          @reply.messages.push(Message.new(:error, error_message[:message], error_message[:exit_code], key))
        end
      end
      respond_with @reply, :status => @reply.status
    return
    end
    
    if not Domain.namespace_available?(namespace)
      @reply = RestReply.new(:unprocessable_entity)
      @reply.messages.push(Message.new(:error, "Namespace '#{namespace}' is already in use. Please choose another.", 103, "namespace"))
      respond_with @reply, :status => @reply.status
    return
    end
    
    cloud_user = CloudUser.find(@login)
    if cloud_user
      @reply = RestReply.new(:conflict)
      @reply.messages.push(Message.new(:error, "User already has a domain associated. Update the domain to modify.", 102))
      respond_with @reply, :status => @reply.status
    return
    end

    #we are using this object for validation until the user and domain are separated
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
      cloud_user.save
    rescue Exception => e
      Rails.logger.error "Failed to create domain #{e.message}"
      @reply = RestReply.new(:internal_server_error)
      @reply.messages.push(Message.new(:error, e.message, e.code))
      respond_with @reply, :status => @reply.status
      return
    end

    domain = RestDomain.new(cloud_user.namespace)
    @reply = RestReply.new(:created, "domain", domain)
    respond_with @reply, :status => @reply.status
  end

  # PUT /domains/<id>
  def update
    id = params[:id]
    new_namespace = params[:namespace]
    Rails.logger.debug "Updating domain #{@cloud_user.namespace} to #{new_namespace}"
    if not @cloud_user or @cloud_user.namespace != id
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "Domain #{id} not found.", 127))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
    return
    end
    
    if not Domain.namespace_available?(new_namespace)
      @reply = RestReply.new(:unprocessable_entity)
      @reply.messages.push(Message.new(:error, "Namespace '#{new_namespace}' already in use. Please choose another.", 103, "namespace"))
      respond_with @reply, :status => @reply.status  do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
    return
    end

    domain = Domain.new(new_namespace)
    if domain.invalid?
      @reply = RestReply.new(:unprocessable_entity)
      domain.errors.keys.each do |key|
        error_messages = domain.errors.get(key)
        error_messages.each do |error_message|
          @reply.messages.push(Message.new(:error, error_message[:message], error_message[:exit_code], key))
        end
      end
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
    return
    end

    begin
      @cloud_user.update_namespace(new_namespace)
    rescue Exception => e
      Rails.logger.error "Failed to update domain #{e.message}"
      @reply = RestReply.new(:internal_server_error)
      @reply.messages.push(Message.new(:error, e.message, e.code))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    @cloud_user = CloudUser.find(@login)
    domain = RestDomain.new(@cloud_user.namespace)
    @reply = RestReply.new(:ok, "domain", domain)
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
      @reply.messages.push(Message.new(:error, "Domain #{id} not found.", 127))
      #respond_with @reply, :status => @reply.status
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
    return
    end

    if force
      Rails.logger.debug "Force deleting domain #{id}"
      @cloud_user.applications.each do |app|
        app.cleanup_and_delete()
      end
    elsif not @cloud_user.applications.empty?
      @reply = RestReply.new(:bad_request)
      @reply.messages.push(Message.new(:error, "Domain contains applications. Delete applications first or set force to true.", 128))

      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
    return
    end

    
    begin
    @cloud_user.delete
    @reply = RestReply.new(:no_content)
    @reply.messages.push(Message.new(:info, "Damain deleted."))
    respond_with(@reply) do |format|
      format.xml { render :xml => @reply, :status => @reply.status }
      format.json { render :json => @reply, :status => @reply.status }
    end
    rescue Exception => e
      Rails.logger.error "Failed to delete domain #{e.message}"
      @reply = RestReply.new(:internal_server_error)
      @reply.messages.push(Message.new(:error, e.message, e.code))
      respond_with(@reply) do |format|
        format.xml { render :xml => @reply, :status => @reply.status }
        format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
  end
end
