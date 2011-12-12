class LegacyBrokerController < ApplicationController
  layout nil
  before_filter :validate_request
  before_filter :authenticate, :except => :cart_list_post
  rescue_from Exception, :with => :exception_handler
  
  def user_info_post
    user = CloudUser.find(@login)
    if user
      user_info = user.as_json
      user_info["ssh_key"] = user_info["ssh"]
      user_info.delete("ssh")
      
      user_info[:rhc_domain] = Rails.application.config.cdk[:domain_suffix]
      app_info = {}
      user.applications.each do |app|
        app_info[app.name] = app.as_json
      end
      
      @reply.data = {:user_info => user_info, :app_info => app_info}.to_json
      render :json => @reply
    else
      # Return a 404 to denote the user doesn't exist
      @reply.resultIO << "User does not exist"
      @reply.exitcode = 99
      
      render :json => @reply, :status => :not_found
    end
  end
  
  def user_manage_post
    user = CloudUser.find(@login)
    if user
      case @req.action
      when "add-user"
        if @req.ssh.nil? or @req.user_name.nil?
          @reply.resultIO << "Must provide 'user-name' and 'ssh' key for the user"
          @reply.exitcode = 105
          render :json => @reply, :status => :invalid
          return
        end
        
        if @req.app_name.nil?
          user.applications.each do |app|
            #add to all applications            
            @reply.append app.add_delegate_user(@req.user_name, @req.ssh)
            app.save
          end
        else
          app = Application.find(user, @req.app_name)
          raise Cloud::Sdk::WorkflowException.new("Application #{@req.app_name} does not exist.", 143), caller[0..5] if app.nil?
          @reply.append app.add_delegate_user(@req.user_name, @req.ssh)
          app.save
        end
      when "remove-user"
        if @req.user_name.nil?
          @reply.resultIO << "Must provide 'user-name'"
          @reply.exitcode = 105
          render :json => @reply, :status => :invalid
          return
        end
        
        if @req.app_name.nil?
          user.applications.each do |app|
            #remove from all applications            
            @reply.append app.remove_delegate_user(@req.user_name)
            app.save
          end
        else
          app = Application.find(user, @req.app_name)
          raise Cloud::Sdk::WorkflowException.new("Application #{@req.app_name} does not exist.", 143), caller[0..5] if app.nil?
          @reply.append app.remove_delegate_user(@req.user_name)
          app.save
        end
      when "list-users"
        app_users = {}
        if @req.app_name.nil?
          user.applications.each do |app|
            app_users[app.name] = app.ssh_keys
          end
        else
          app = Application.find(user, @req.app_name)
          raise Cloud::Sdk::WorkflowException.new("Application #{@req.app_name} does not exist.", 143), caller[0..5] if app.nil?
          app_users[app.name] = app.ssh_keys
        end
        
        @reply.data = { :app_users => app_users }.to_json
      end
      render :json => @reply
    else
      # Return a 404 to denote the user doesn't exist
      @reply.result << "User does not exist"
      @reply.exitcode = 99
      
      render :json => @reply, :status => :not_found
    end
  end
  
  def domain_post
    cloud_user = CloudUser.find(@login)
    if @req.alter
      cloud_user.ssh = @req.ssh
      cloud_user.namespace = @req.namespace
    elsif @req.delete
       if not cloud_user.applications.empty?
         res_string = "Cannot remove namespace #{cloud_user.namespace}. Remove existing apps first.\n"
         cloud_user.applications.each { |app|
	   res_string += app.name 
           res_string += "\n" 
         }
         @reply.resultIO << res_string
         @reply.exitcode = 106 
         render :json => @reply, :status => :invalid
         return
       end
       dns_service = Cloud::Sdk::DnsService.instance
       dns_service.deregister_namespace(cloud_user.namespace)      
       dns_service.publish        
       dns_service.close
       @reply.resultIO << "Namespace #{cloud_user.namespace} deleted successfully.\n"
       cloud_user.delete
       render :json => @reply
       return
    else
      cloud_user = CloudUser.new(@login, @req.ssh, @req.namespace)
    end
        
    if cloud_user.invalid?
      @reply.resultIO << cloud_user.errors.first[1]
      render :json => @reply, :status => :invalid 
      return
    end
        
    @reply.append cloud_user.save
    @reply.data = {
      :rhlogin    => cloud_user.rhlogin,
      :uuid       => cloud_user.uuid,
      :rhc_domain => Rails.application.config.cdk[:domain_suffix]
    }
      
    render :json => @reply
  end
  
  def cart_list_post
    cart_type = @req.cart_type
    unless cart_type
      @reply.resultIO << "Invalid cartridge types: #{cart_type} specified"
      @reply.exitcode = 109
      render :json => @reply, :status => :invalid
      return
    end
  
    carts = Application.get_available_cartridges(cart_type)
    @reply.data = { :carts => carts }.to_json
    render :json => @reply
  end
  
  def cartridge_post
    @req.node_profile ||= "std"
    user = CloudUser.find(@login)
    
    case @req.action
    when 'configure'    #create app and configure framework
      cart_type = @req.cartridge.split('-')[0..-2].join('-')
      apps = user.applications
      
      app = Application.new(user, @req.app_name, nil, @req.node_profile, @req.cartridge)
      if app.valid?
        begin
          @reply.append app.create          
          app.save
          @reply.append app.configure_dependencies          
          @reply.append app.add_system_ssh_keys
          @reply.append app.add_system_env_vars
          @reply.append app.create_dns
          
          case app.framework_cartridge
            when 'php'
              page = 'health_check.php'
            when 'perl'
              page = 'health_check.pl'
            else
              page = 'health'
          end
        
          @reply.data = {:health_check_path => page, :uuid => app.uuid}.to_json
        rescue Exception => e
          Rails.logger.debug e.message
          Rails.logger.debug e.backtrace.inspect          
          @reply.append app.destroy_dns
          @reply.append app.destroy
          app.delete
        end
        @reply.resultIO << "Successfully created application: #{app.name}" if @reply.resultIO.string.empty?
      else
        @reply.result = app.errors.first[1]
        render :json => @reply, :status => :invalid 
        return
      end
    when 'deconfigure'
      app = Application.find(user, @req.app_name)
      @reply.append app.destroy
      
      if app.framework_cartridge == "jenkins"
        user.applications.each do |uapp|
          @reply.append uapp.remove_dependency('jenkins-client-1.4') if uapp.name != app.name and uapp.embedded and uapp.embedded.has_key?('jenkins-client-1.4')
        end
      end
      
      @reply.append app.destroy_dns
      app.delete
      @reply.resultIO << "Successfully destroyed application: #{app.name}" if @reply.resultIO.string.empty?
    when 'start'
      app = Application.find(user, @req.app_name)
      @reply.append app.start
    when 'stop'
      app = Application.find(user, @req.app_name)
      @reply.append app.stop
    when 'restart'
      app = Application.find(user, @req.app_name)
      @reply.append app.restart
    when 'force-stop'
      app = Application.find(user, @req.app_name)
      @reply.append app.force_stop
    when 'reload'
      app = Application.find(user, @req.app_name)
      @reply.append app.reload
    when 'status'
      app = Application.find(user, @req.app_name)
      @reply.append app.status
    when 'tidy'
      app = Application.find(user, @req.app_name)
      @reply.append app.tidy      
    when 'add-alias'
      app = Application.find(user, @req.app_name)
      @reply.append app.add_alias @req.server_alias
    when 'remove-alias'
      app = Application.find(user, @req.app_name)
      @reply.append app.remove_alias @req.server_alias
    else
      #unrecognized command
    end
    @reply.resultIO << 'Success' if @reply.resultIO.string.empty?
    
    render :json => @reply
  end
  
  def embed_cartridge_post
    user = CloudUser.find(@login)    
    app = Application.find(user, @req.app_name)

    Rails.logger.debug "DEBUG: Performing action '#{@req.action}' on node '#{app.server_identity}'"    
    case @req.action
    when 'configure'
      @reply.append app.add_dependency(@req.cartridge)
    when 'deconfigure'
      @reply.append app.remove_dependency(@req.cartridge)
    when 'start'
      @reply.append app.start_dependency(@req.cartridge)      
    when 'stop'
      @reply.append app.stop_dependency(@req.cartridge)      
    when 'restart'
      @reply.append app.restart_dependency(@req.cartridge)      
    when 'status'
      @reply.append app.dependency_status(@req.cartridge)      
    when 'reload'
      @reply.append app.reload_dependency(@req.cartridge)      
    end
        
    @reply.resultIO << 'Success' if @reply.resultIO.string.empty?
    render :json => @reply
  end
  
  protected
  
  def validate_request
    @reply = ResultIO.new
    begin
      @req = LegacyRequest.new.from_json(params['json_data'])
      if @req.invalid?
        @reply.resultIO << @req.errors.first[1]
        render :json => @reply, :status => :invalid 
      end
    end
  end
  
  def authenticate
    @login = Cloud::Sdk::AuthService.instance.login(request, params, cookies)
    unless @login
      @reply.resultIO << "Invalid user credentials"
      @reply.exitcode = 97
      render :json => @reply, :status => :unauthorized
    end
  end
  
  def exception_handler(e)
    status = :internal_server_error
    case e
    when Cloud::Sdk::AuthServiceException
      logger.error "AuthenticationException rescued in #{request.path}"
      logger.error e.message
      logger.error e.backtrace
      @reply.append e.resultIO if e.resultIO
      @reply.resultIO << "An error occurred while contacting the authentication service. If the problem persists please contact Red Hat support."
    when Cloud::Sdk::WorkflowException
      logger.error "WorkflowException rescued in #{request.path}"
      logger.error e.message
      @reply.append e.resultIO if e.resultIO      
      @reply.debugIO << e.message
      @reply.debugIO << e.backtrace[0..5].join("\n")
      @reply.messageIO << e.message
      status = :bad_request
    when Cloud::Sdk::CdkException
      logger.error "Exception rescued in #{request.path}:"
      logger.error e.message
      logger.error e.backtrace
      @reply.append e.resultIO if e.resultIO      
      @reply.messageIO << "An internal error occurred [code: #{e.code}]. If the problem persists please contact support."
    else
      logger.error "Exception rescued in #{request.path}:"
      logger.error e.message
      logger.error e.backtrace
      @reply.debugIO << e.message
      @reply.debugIO << e.backtrace[0..5].join("\n")
      @reply.messageIO << e.message
    end
    
    @reply.exitcode = e.respond_to?('exit_code') ? e.exit_code : 1
    render :json => @reply, :status => status
  end
end
