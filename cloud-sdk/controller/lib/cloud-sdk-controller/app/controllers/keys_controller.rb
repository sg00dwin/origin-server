class KeysController < BaseController
  respond_to :xml, :json
  before_filter :authenticate
  include LegacyBrokerHelper
  
  def index
    user = CloudUser.find(@login)
    if(user.nil?)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "User #{@login} not found"))
      respond_with @reply, :status => @reply.status
      return
    end
    keys = Array.new
    user.ssh_keys.each do |name, key, type|
      ssh = RestSshKey.new(name, type, key)
      keys.push(s)
    end
    @reply = RestReply.new(:ok, "SSH", [user.ssh_keys, keys])
    respond_with @reply, :status => @reply.status
  end
  
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
      user.ssh_keys.each do |key|
        if key == name
          @reply = RestReply.new(:ok, "SSH key", key)
          respond_with @reply, :status => @reply.status
          return
        end
      end
    else
       @reply = RestReply.new(:not_found)
       @reply.messages.push(Message.new(:error, "SSH key #{name} for user #{@login} not found"))
       respond_with @reply, :status => @reply.status
       return
    end
  end
  
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
          @reply.messages.push(Message.new(:error, "Key with name #{name} already exists. Please choose a different name"))
          respond_with @reply, :status => @reply.status
          return
        end
        if key == ssh
          @reply = RestReply.new(:conflict)
          @reply.messages.push(Message.new(:error, "Given public key is already in use. Use different key or delete conflicting key and retry"))
          respond_with @reply, :status => @reply.status
          return
        end
      end
    end
    
    begin
      user.add_secondary_ssh_key(name, ssh, type)
      user.save
      @reply = RestReply.new(:created, "user", RestUser.new(user))
      @reply.messages.push(Message.new(:info, "Created key #{name} for user #{@login}"))
      respond_with @reply, :status => @reply.status
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      @reply.messages.push(Message.new(:error, "Failed to create ssh key for user #{@login}") )
      @reply.messages.push(Message.new(:error, e.message))
      respond_with @reply, :status => @reply.status
      return
    end
  end
  
  def update
    ssh = params[:ssh]
    name = params[:id]
    type = params[:type]
    
    user = CloudUser.find(@login)
    if(user.nil?)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "User #{@login} not found"))
      respond_with @reply, :status => @reply.status
      return
    end
    
    if ssh.nil? or name.nil?
      @reply = RestReply.new(:bad_request)
      @reply.messages.push(Message.new(:error, "Missing required parameters ssh or name"))
      respond_with @reply, :status => @reply.status
      return
    end
    
    if user.ssh_keys.nil? or not user.ssh_keys.has_key?(name)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "Key with name #{name} not found for user #{@login}"))
      respond_with @reply, :status => @reply.status
      return
    end

    begin
      user.remove_secondary_ssh_key(name)
      user.add_secondary_ssh_key(name, ssh, type)
      user.save
      @reply = RestReply.new(:ok, "user", RestUser.new(user))
      @reply.messages.push(Message.new(:info, "Updated key with name #{name} for user #{@login}"))
      respond_with @reply, :status => @reply.status
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      @reply.messages.push(Message.new(:error, "Failed to update key #{name} for user #{@login}") )
      @reply.messages.push(Message.new(:error, e.message))
      respond_with @reply, :status => @reply.status
      return
    end
  end
  
  def destroy
    name = params[:id]
    
    user = CloudUser.find(@login)
    if(user.nil?)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "User #{@login} not found"))
      respond_with @reply, :status => @reply.status
      return
    end
    
    if name.nil?
      @reply = RestReply.new(:bad_request)
      @reply.messages.push(Message.new(:error, "Missing required parameter name"))
      respond_with @reply, :status => @reply.status
      return
    end
    
    if user.ssh_keys.nil? or not user.ssh_keys.has_key?(name)
      @reply = RestReply.new(:not_found)
      @reply.messages.push(Message.new(:error, "Key with name #{name} not found for user #{@login}"))
      respond_with @reply, :status => @reply.status
      return
    end

    begin
      user.remove_secondary_ssh_key(name)
      user.save
      @reply = RestReply.new(:no_content, "user", RestUser.new(user))
      @reply.messages.push(Message.new(:info, "Removed key with name #{name} for user #{@login}"))
      respond_with @reply, :status => @reply.status
    rescue Exception => e
      @reply = RestReply.new(:internal_server_error)
      @reply.messages.push(Message.new(:error, "Failed to remove key #{name} for user #{@login}") )
      @reply.messages.push(Message.new(:error, e.message))
      respond_with @reply, :status => @reply.status
      return
    end
  end
end