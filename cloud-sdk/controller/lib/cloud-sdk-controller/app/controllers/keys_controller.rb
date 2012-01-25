class KeysController < BaseController
  respond_to :xml, :json
  before_filter :authenticate
  include LegacyBrokerHelper
  
  #GET /user/keys
  def index
    user = CloudUser.find(@login)
    if(user.nil?)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "User #{@login} not found"))
      respond_with @reply, :status => @reply.status
      return
    end
    ssh_keys = Array.new
    unless user.ssh_keys.nil?
      user.ssh_keys.each do |name, key|
        ssh_key = RestSshKey.new(name, key)
        ssh_keys.push(ssh_key)
      end
    end
    @reply = RestReply.new(:ok, "SSH", ssh_keys)
    respond_with @reply, :status => @reply.status
  end
  
  #GET /user/keys/<id>
  def show 
    name = params[:id]
    user = CloudUser.find(@login)
    if user.nil? or user.ssh_keys.nil?
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "User #{@login} not found"))
      respond_with @reply, :status => @reply.status
      return
    end
    if user.ssh_keys
      user.ssh_keys.each do |key_name, key|
        if key_name == name
          @reply = RestReply.new(:ok, "SSH key", RestSshKey.new(key_name, key))
          respond_with @reply, :status => @reply.status
          return
        end
      end
    end

    @reply = RestReply.new(:not_found)
    @reply.messages.push(Message.new(:error, "SSH key #{name} for user #{@login} not found"))
    respond_with @reply, :status => @reply.status
  end
  
  #POST /user/keys
  def create
    ssh = params[:ssh]
    name = params[:name]
    type = params[:type]
    
    user = CloudUser.find(@login)
    if(user.nil?)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "User #{@login} not found"))
      respond_with @reply, :status => @reply.status
      return
    end
    
    if ssh.nil? or name.nil? or type.nil?
      @reply = RestReply.new(:bad_request)
      @reply.messages.push(Message.new(:error, "Missing required parameters name, ssh or type"))
      respond_with @reply, :status => @reply.status
      return
    end
    #check to see if key already exists
    if user.ssh_keys
      user.ssh_keys.each do |key_name, key|
        if key_name == name
          @reply = RestReply.new(:conflict)
          @reply.messages.push(Message.new(:error, "SSH key with name #{name} already exists. Please choose a different name"))
          respond_with @reply, :status => @reply.status
          return
        end
        #TODO fix this
        if key["ssh"] == ssh
          @reply = RestReply.new(:conflict)
          @reply.messages.push(Message.new(:error, "Given public key is already in use. Use different key or delete conflicting key and retry"))
          respond_with @reply, :status => @reply.status
          return
        end
      end
    end
    
    begin
      user.add_ssh_key(name, ssh, type)
      user.save
      ssh_key = RestSshKey.new(name, user.ssh_keys[name])
      @reply = RestReply.new(:created, "SSH key", ssh_key)
      @reply.messages.push(Message.new(:info, "Created SSH key #{name} for user #{@login}"))
      respond_with @reply, :status => @reply.status
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      @reply.messages.push(Message.new(:error, "Failed to create SSH key for user #{@login}") )
      @reply.messages.push(Message.new(:error, e.message))
      respond_with @reply, :status => @reply.status
      return
    end
  end
  
  #PUT /user/keys/<id>
  def update
    ssh = params[:ssh]
    name = params[:id]
    type = params[:type]
    
    user = CloudUser.find(@login)
    if(user.nil?)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "User #{@login} not found"))
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    
    if ssh.nil? or name.nil? or type.nil?
      @reply = RestReply.new(:bad_request)
      @reply.messages.push(Message.new(:error, "Missing required parameters name, type or ssh"))
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    
    if user.ssh_keys.nil? or not user.ssh_keys.has_key?(name)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "SSH key with name #{name} not found for user #{@login}"))
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end

    begin
      user.remove_ssh_key(name)
      user.add_ssh_key(name, ssh, type)
      user.save
      ssh_key = RestSshKey.new(name, user.ssh_keys[name])
      @reply = RestReply.new(:ok, "SSH key", ssh_key)
      @reply.messages.push(Message.new(:info, "Updated SSH key with name #{name} for user #{@login}"))
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      @reply.messages.push(Message.new(:error, "Failed to update SSH key #{name} for user #{@login}") )
      @reply.messages.push(Message.new(:error, e.message))
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
  end
  
  #DELETE /user/keys/<id>
  def destroy
    name = params[:id]
    
    user = CloudUser.find(@login)
    if(user.nil?)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "User #{@login} not found"))
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    
    if name.nil?
      @reply = RestReply.new(:bad_request)
      @reply.messages.push(Message.new(:error, "Missing required parameter name"))
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
    
    if user.ssh_keys.nil? or not user.ssh_keys.has_key?(name)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "SSH key with name #{name} not found for user #{@login}"))
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end

    begin
      user.remove_ssh_key(name)
      user.save
      @reply = RestReply.new(:no_content)
      @reply.messages.push(Message.new(:info, "Deleted SSH key #{name} for user #{@login}"))
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      @reply.messages.push(Message.new(:error, "Failed to delete SSH key #{name} for user #{@login}") )
      @reply.messages.push(Message.new(:error, e.message))
      respond_with(@reply) do |format|
         format.xml { render :xml => @reply, :status => @reply.status }
         format.json { render :json => @reply, :status => @reply.status }
      end
      return
    end
  end
end
