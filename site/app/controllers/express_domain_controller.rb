class ExpressDomainController < ApplicationController
  before_filter :require_login
  before_filter :require_user, :only => [:edit_namespace, :edit_sshkey, :account_update]

  def create
    # Get only relevant parameters
    domain_params = params[:express_domain]

    # Make sure that if there is an SSH key provided, it's valid
    if ssh = domain_params[:ssh]
      @ssh_key_validation = validate_ssh(ssh)
      if @ssh_key_validation[:valid]
        # Ensure we only send the key until the broker supports comments
        domain_params[:ssh] = "#{@ssh_key_validation[:type]} #{@ssh_key_validation[:key]}"
      else
        ssh_invalid = true
      end
    else
      domain_params[:ssh] = 'ssh-rsa nossh'
    end

    # check for which domain action we should call
    @dom_action = domain_params.delete :dom_action
    form_type = domain_params.delete :form_type
    @event = "#{form_type.gsub(/[^\w]/, '')}_form_return"

    if !ssh_invalid

      Rails.logger.debug "dom_action: #{@dom_action}"
      domain_params[:rhlogin] = session[:login]
      domain_params[:ticket] = cookies[:rh_sso]
      domain_params[:password] = ''
      @domain = ExpressDomain.new(domain_params)
      ajax_response = {}
      if @domain.valid?
        begin
          if @dom_action == 'create'
            Rails.logger.debug 'creating domain'
            @domain.create do |json_response|
              ajax_response = process_response json_response
            end
          elsif @dom_action == 'update'
            @domain.update do |json_response|
              ajax_response = process_response json_response
            end
          end #end if action
        rescue Exception
          # Exception messages are recorded in the error hash in ExpressApi
          @message = @domain.errors.full_messages.join("; ")
          @message_type = :error
          ajax_response = {:status => 'error', :data => @message, :event => @event}
        end
      else
        # display validation errors
        @message = @domain.errors.full_messages.join("; ")
        @message_type = :error
        Rails.logger.error "Validation error: #{@message}"
        ajax_response = {:status => 'error', :data => @message, :event => @event}
      end
    else
      @message = "The SSH key supplied was invalid"
      @message_type = :error
      Rails.logger.error "Validation error: #{@message}"
      ajax_response = {:status => 'error', :data => @message, :event => @event}
    end

    # respond based on requested format
    respond_to do |format|
      format.html do
        flash[@message_type] = @message
        redirect_to :controller => 'control_panel'
      end
      format.js do
        render(:json => ajax_response, :status => ajax_response[:status] ) and return
      end
    end
  end

  def edit_namespace
    if @userinfo.namespace
      @dom_action = 'update'
    else
      @dom_action = 'create'
    end
    @domain = ExpressDomain.new :rhlogin => @userinfo.rhlogin, :namespace => @userinfo.namespace
    render :layout => 'console'
  end

  def edit_sshkey
    @dom_action = 'update'
    @domain = ExpressDomain.new :rhlogin => @userinfo.rhlogin, :namespace => @userinfo.namespace
  end

  def save_domain
    response = {}
    if @domain.valid?
      begin
        if @dom_action == 'create'
          Rails.logger.debug 'creating domain'
          @domain.create do |json_response|
            response = process_response json_response
          end
        else
          @domain.update do |json_response|
            response = process_response json_response
          end
        end
      rescue Exception
        @message = @domain.errors.full_messages.join("; ")
        @message_type = :error
        response = {:status => 'error', :data => @message, :event => @event}
      end
    else
      # display validation errors
      @message = @domain.errors.full_messages.join("; ")
      @message_type = :error
      Rails.logger.error "Validation error: #{@message}"
      response = {:status => 'error', :data => @message, :event => @event}
    end
    return response
  end

  def account_update
    # Get only relevant parameters
    domain_params = params[:express_domain]

    domain_params[:rhlogin] = session[:login]
    domain_params[:ticket] = cookies[:rh_sso]
    domain_params[:password] = ''

    @dom_action = domain_params.delete :dom_action
    form_type = domain_params.delete :form_type

    # start from assuming the key is invalid
    ssh_invalid = true
    if form_type == 'sshkey':
      # ssh keys are always updated
      @dom_action = 'update_ssh'
      domain_params[:namespace] = @userinfo.namespace
      if ssh = domain_params[:ssh]
        @ssh_key_validation = validate_ssh(ssh)
        if @ssh_key_validation[:valid]
          # Ensure we only send the key until the broker supports comments
          domain_params[:ssh] = "#{@ssh_key_validation[:type]} #{@ssh_key_validation[:key]}"
          ssh_invalid = false
        end
      end
    else
      # userinfo previously validated ssh key so no need to do so again
      ssh_invalid = false
      ssh = @userinfo.key_type.to_s + " " + @userinfo.ssh_key.to_s

      if ssh.to_s.strip.length != 0
        domain_params[:ssh] = ssh
      else
        domain_params[:ssh] = 'ssh-rsa nossh'
      end
    end

    @domain = ExpressDomain.new(domain_params)

    if !ssh_invalid
      response = save_domain
    else
      @message = "The SSH key supplied was invalid"
      @message_type = :error
      Rails.logger.error "Validation error: #{@message}"
      response = {:status => 'error', :data => @message, :event => @event}
    end

    respond_to do |format|
      if @message_type == :error
        format.html do
          flash[@message_type] = @message
          if form_type == 'sshkey':
            render :action => :edit_sshkey and return
          else
            render :action => :edit_namespace and return
          end
        end
        format.js { render :json => response }
      else
        flash[@message_type] = @message
        format.html { redirect_to account_path }
        format.js { render :json => response }
      end
    end
  end


  def process_response(json_response)
    Rails.logger.debug "Domain api result: #{json_response.inspect}"
    # check that we have expected result
    unless json_response["exit_code"] > 0
      @message = I18n.t("express_api.messages.domain_#{@dom_action}")
      @message_type = :success
      Rails.logger.debug 'success of domain'
      success_data = {
        :action => @dom_action,
        :namespace => params[:express_domain][:namespace],
        :ssh => @domain.ssh
      }
      response = {:status => 'success', :event => @event, :data => success_data}
    else
      # broker error
      @message = json_response["result"].empty? ? I18n.t(:unknown) : json_response["result"]
      @message_type = :error
      response = {:status => 'error', :data => @message, :event => @event}
    end
    return response
  end

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
end
