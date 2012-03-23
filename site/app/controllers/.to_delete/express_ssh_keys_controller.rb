class ExpressSshKeysController < ApplicationController
  before_filter :require_login

  def create
    @express_ssh_key = ExpressSshKey.new params[:express_ssh_key]
    @express_ssh_key.rhlogin = session[:login]
    @express_ssh_key.ticket = session[:ticket]

    # validate the ssh key
    ssh_invalid = false
    if @express_ssh_key.key_string.strip.length == 0
      @message = "The SSH key is required"
      ssh_invalid = true
    elsif @express_ssh_key.name.to_s.strip.length == 0
      @message = "The SSH key name is required"
      ssh_invalid = true
    else
      @ssh_key_validation = validate_ssh(@express_ssh_key.key_string)
      if @ssh_key_validation[:valid]
        @userinfo = ExpressUserinfo.new :rhlogin => session[:login],
                                        :ticket => session[:ticket]
        @userinfo.establish
        @express_ssh_key.namespace = @userinfo.namespace
    
        ajax_response = {}
        if @express_ssh_key.mode == "update"
          @express_ssh_key.update 
        else
          @express_ssh_key.create
        end
    
        if !@express_ssh_key.errors.empty?
          @message = "Failed to #{@express_ssh_key.mode} SSH key"
          Rails.logger.error "ssh key add/update errors: #{@express_ssh_key.errors}"
          ssh_invalid = true
        end

        @ssh_keys = @userinfo.ssh_keys
        @primary_ssh_key = default_key(@ssh_keys)
      else
        @message = "The SSH key supplied was invalid"
        ssh_invalid = true
      end
    end

    if ssh_invalid
      @message_type = :error
      Rails.logger.error "Validation error: #{@message}"
      ajax_response = {:status => 'error', :data => @message, :event => @event}
    else
      @message_type = :success
      @message = "Successfully #{@express_ssh_key.mode == 'update' ? 'updated' : 'added'} SSH key"
    end
    

    # respond based on requested format
    respond_to do |format|
      format.html do
        flash[@message_type] = @message
        
        if !ssh_invalid
          redirect_to :controller => 'user', :action => 'show'
        else
          if @express_ssh_key.mode == 'update'
            redirect_to :controller => "express_ssh_keys", :action => "edit_sshkey", :key_name => @express_ssh_key.name
          else
            redirect_to add_sshkey_express_sshkeys_path
          end
        end
      end
      format.js do
        render(:json => ajax_response, :status => ajax_response[:status] ) and return
      end
    end
  end

  def add_sshkey
    @dom_action = 'add'
    @userinfo = ExpressUserinfo.new :rhlogin => session[:login],
                                    :ticket => session[:ticket]
    @userinfo.establish
    @domain = ExpressDomain.new :rhlogin => @userinfo.rhlogin, :namespace => @userinfo.namespace
    @express_ssh_key = ExpressSshKey.new
  end

  def edit_sshkey
    @dom_action = 'update'
    @userinfo = ExpressUserinfo.new :rhlogin => session[:login],
                                    :ticket => session[:ticket]
    @userinfo.establish
    @express_ssh_key = find_key(@userinfo.ssh_keys, params[:key_name])
    @domain = ExpressDomain.new :rhlogin => @userinfo.rhlogin, :namespace => @userinfo.namespace
  end

  def delete_sshkey
    @userinfo = ExpressUserinfo.new :rhlogin => session[:login],
                                    :ticket => session[:ticket]
    @userinfo.establish
    @express_ssh_key = find_key(@userinfo.ssh_keys, params[:key_name])
    @express_ssh_key.rhlogin = session[:login]
    @express_ssh_key.ticket = session[:ticket]
    @express_ssh_key.destroy


    @userinfo = ExpressUserinfo.new :rhlogin => session[:login],
                                    :ticket => session[:ticket]
    @userinfo.establish
    @ssh_keys = @userinfo.ssh_keys
    @primary_ssh_key = default_key(@ssh_keys)
    
    redirect_to :controller => 'user', :action => 'show'
  end

  private

  def validate_ssh(ssh)
    type_regex = /^ssh-(rsa|dss)$/
    key_regex =  /^[A-Za-z0-9+\/]+[=]*$/
    type_required = true

    values = { :valid => true }
    parts = ssh.split

    case parts.length
    when 1
      values[:key] = parts[0]
    when 2
      if type_regex.match(parts[0])
        values[:type] = parts[0]
        values[:key] = parts[1]
      else
        values[:key] = parts[0]
        values[:comment] = parts[1]
      end
    when 3
      values[:type] = parts[0]
      values[:key] = parts[1]
      values[:comment] = parts[2]
    end

    if type_required && !values[:type]
      values[:valid] = false
    end

    if values[:type] && !type_regex.match(values[:type])
      values[:valid] = false
    end

    if values[:key] && !key_regex.match(values[:key])
      values[:valid] = false
    end
    values
  end

  def default_key(keys)
    default = nil
    keys.each do |key|
      if key.primary?
        default = key
      end
    end

    default || ExpressSshKey.new(:primary => true)
  end

  def find_key(keys, key_name)
    keys.each do |key|
      if key.name == key_name
        return key
      end
    end
    return nil
  end

end