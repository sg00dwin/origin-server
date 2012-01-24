class LegacyBrokerController < ApplicationController
  layout nil
  before_filter :validate_request, :process_notification
  before_filter :authenticate, :except => :cart_list_post
  rescue_from Exception, :with => :exception_handler
  include LegacyBrokerHelper
  
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
  
  def ssh_keys_post
    user = CloudUser.find(@login)
    if user
      case @req.action
      when "add-key"
        raise Cloud::Sdk::UserKeyException.new("Missing SSH key or key name", 119) if @req.ssh.nil? or @req.key_name.nil?
        if user.ssh_keys
          user.ssh_keys.each do |key_name, key|
            raise Cloud::Sdk::UserKeyException.new("Key with name #{@req.key_name} already exists. Please choose a different name", 120) if key_name == @req.key_name
            raise Cloud::Sdk::UserKeyException.new("Given public key is already in use. Use different key or delete conflicting key and retry", 121) if key == @req.ssh
          end
        end
        @reply.append user.add_secondary_ssh_key(@req.key_name, @req.ssh, @req.key_type)
        user.save
      when "remove-key"
        raise Cloud::Sdk::UserKeyException.new("Missing key name", 119) if @req.key_name.nil?
        @reply.append user.remove_secondary_ssh_key(@req.key_name)
        user.save
      when "update-key"
        raise Cloud::Sdk::UserKeyException.new("Missing SSH key or key name", 119) if @req.ssh.nil? or @req.key_name.nil?
        @reply.append user.remove_secondary_ssh_key(@req.key_name)
        @reply.append user.add_secondary_ssh_key(@req.key_name, @req.ssh, @req.key_type)
      when "list-keys"
        @reply.data = { :keys => user.ssh_keys }.to_json
      else
        raise Cloud::Sdk::UserKeyException.new("Invalid action #{@req.action}", 111)
      end
      render :json => @reply
    else
      raise Cloud::Sdk::UserException.new("Invalid user", 99)
    end
  end
  
  def domain_post
    cloud_user = CloudUser.find(@login)

    if !cloud_user && (@req.alter || @req.delete)
      @reply.resultIO << "Cannot alter or remove namespace #{@req.namespace}. Namspace does not exist.\n"
      render :json => @reply, :status => :bad_request
      return
    end

    if @req.alter
      @reply.append cloud_user.update_ssh_key(@req.ssh, @req.key_type)
      
      raise Cloud::Sdk::UserException.new("The supplied namespace '#{@req.namespace}' is not allowed", 106) if Cloud::Sdk::ApplicationContainerProxy.blacklisted? @req.namespace            
      @reply.append cloud_user.update_namespace(@req.namespace)
    elsif @req.delete
       if  @req.namespace != cloud_user.namespace
         @reply.resultIO << "Cannot remove namespace #{@req.namespace}. This namespace is not associated with rhlogin: #{cloud_user.rhlogin}\n"
         @reply.exitcode = 106
         render :json => @reply, :status => :bad_request
         return
       end
       if not cloud_user.applications.empty?
         @reply.resultIO << "Cannot remove namespace #{cloud_user.namespace}. Remove existing apps first.\n"
         @reply.resultIO << cloud_user.applications.map{|a| a.name}.join("\n")
         @reply.exitcode = 106 
         render :json => @reply, :status => :bad_request
         return
       end
       @reply.append cloud_user.delete
       render :json => @reply
       return
    else
      raise Cloud::Sdk::UserException.new("The supplied namespace '#{@req.namespace}' is not allowed", 106) if Cloud::Sdk::ApplicationContainerProxy.blacklisted? @req.namespace
      cloud_user = CloudUser.new(@login, @req.ssh, @req.namespace, @req.key_type)
      if cloud_user.invalid?
        @reply.resultIO << cloud_user.errors.first[1][:message]
        render :json => @reply, :status => :bad_request 
        return
      end
    end

    @reply.append cloud_user.save
    @reply.data = {
      :rhlogin    => cloud_user.rhlogin,
      :uuid       => cloud_user.uuid,
      :rhc_domain => Rails.application.config.cdk[:domain_suffix]
    }.to_json
      
    render :json => @reply
  end
  
  def cart_list_post
    cart_type = @req.cart_type                                                                                                                                                                                                                                    
    unless cart_type
      @reply.resultIO << "Invalid cartridge types: #{cart_type} specified"
      @reply.exitcode = 109
      render :json => @reply, :status => :bad_request
      return
    end
  
    cache_key = "cart_list_#{cart_type}"                                                                                                                                                                                                 
    carts = get_cached(cache_key, :expires_in => 21600.seconds) {
      Application.get_available_cartridges(cart_type)
    }
    @reply.data = { :carts => carts }.to_json
    render :json => @reply
  end
  
  def cartridge_post
    @req.node_profile ||= "std"
    user = CloudUser.find(@login)
    raise Cloud::Sdk::UserException.new("Invalid user", 99) if user.nil?
    
    case @req.action
    when 'configure'    #create app and configure framework
      apps = user.applications

      app = Application.new(user, @req.app_name, nil, @req.node_profile, @req.cartridge)
      container = Cloud::Sdk::ApplicationContainerProxy.find_available(@req.node_profile)
      check_cartridge_type(app.framework, container, "standalone")
      if (user.consumed_gears >= user.max_gears)
        raise Cloud::Sdk::UserException.new("#{@login} has already reached the application limit of #{user.max_gears}", 104)
      end
      raise Cloud::Sdk::UserException.new("The supplied application name '#{app.name}' is not allowed", 105) if Cloud::Sdk::ApplicationContainerProxy.blacklisted? app.name
      if app.valid?
        begin
          @reply.append app.create(container)
          @reply.append app.configure_dependencies
          @reply.append app.add_system_ssh_keys
          @reply.append app.add_secondary_ssh_keys
          @reply.append app.add_system_env_vars
          begin
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
            @reply.append app.destroy_dns
            raise
          end
        rescue Exception => e
          if app.persisted?
            Rails.logger.debug e.message
            Rails.logger.debug e.backtrace.inspect
            @reply.append app.deconfigure_dependencies
            @reply.append app.destroy
            app.delete
          end
          raise
        end
        @reply.resultIO << "Successfully created application: #{app.name}" if @reply.resultIO.length == 0
      else
        @reply.result = app.errors.first[1][:message]
        render :json => @reply, :status => :bad_request 
        return
      end
    when 'deconfigure'
      app = get_app_from_request(user)      
      @reply.append app.cleanup_and_delete
      @reply.resultIO << "Successfully destroyed application: #{app.name}" if @reply.resultIO.length == 0
    when 'start'
      app = get_app_from_request(user)
      @reply.append app.start
    when 'stop'
      app = get_app_from_request(user)
      @reply.append app.stop
    when 'restart'
      app = get_app_from_request(user)
      @reply.append app.restart
    when 'force-stop'
      app = get_app_from_request(user)
      @reply.append app.force_stop
    when 'reload'
      app = get_app_from_request(user)
      @reply.append app.reload
    when 'status'
      app = get_app_from_request(user)
      @reply.append app.status
    when 'tidy'
      app = get_app_from_request(user)
      @reply.append app.tidy      
    when 'add-alias'
      app = get_app_from_request(user)
      @reply.append app.add_alias @req.server_alias
    when 'remove-alias'
      app = get_app_from_request(user)
      @reply.append app.remove_alias @req.server_alias
    when 'threaddump'
      app = get_app_from_request(user)
      @reply.append app.threaddump
    else
      raise Cloud::Sdk::UserException.new("Invalid action #{@req.action}", 111)
    end
    @reply.resultIO << 'Success' if @reply.resultIO.length == 0
    
    render :json => @reply
  end
  
  def embed_cartridge_post
    user = CloudUser.find(@login)    
    raise Cloud::Sdk::UserException.new("Invalid user", 99) if user.nil?
        
    app = get_app_from_request(user)
    
    check_cartridge_type(@req.cartridge, app.container, "embedded")

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
    else
      raise Cloud::Sdk::UserException.new("Invalid action #{@req.action}", 111)           
    end
        
    @reply.resultIO << 'Success' if @reply.resultIO.length == 0
    render :json => @reply
  end
  
  protected
  
  def process_notification
    message = self.notifications if self.respond_to? "notifications"
    @reply.messageIO << message unless message.nil?
  end
  
  # Raise an exception if cartridge type isn't supported
  def check_cartridge_type(framework, container, cart_type)
    carts = container.get_available_cartridges(cart_type)
    unless carts.include? framework
      if cart_type == 'standalone'
        raise Cloud::Sdk::UserException.new(110), "Invalid application type (-t|--type) specified: '#{framework}'.  Valid application types are (#{carts.join(', ')})."
      else
        raise Cloud::Sdk::UserException.new(110), "Invalid type (-e|--embed) specified: '#{framework}'.  Valid embedded types are (#{carts.join(', ')})."
      end
    end
  end
  
  def get_app_from_request(user)
    app = Application.find(user, @req.app_name)
    raise Cloud::Sdk::UserException.new("An application named '#{@req.app_name}' does not exist", 101) if app.nil?
    return app
  end
  
  def validate_request
    @reply = ResultIO.new
    begin
      @req = LegacyRequest.new.from_json(params['json_data'])
      if @req.invalid?
        @reply.resultIO << @req.errors.first[1][:message]
        render :json => @reply, :status => :bad_request 
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
      logger.error e.backtrace[0..5].join("\n")
      @reply.append e.resultIO if e.resultIO
      @reply.resultIO << "An error occurred while contacting the authentication service. If the problem persists please contact Red Hat support." if @reply.resultIO.length == 0
    when Cloud::Sdk::UserException
      @reply.resultIO << e.message
      status = :bad_request
    when Cloud::Sdk::CdkException
      logger.error "Exception rescued in #{request.path}:"
      logger.error e.message
      logger.error e.backtrace[0..5].join("\n")
      logger.error e.resultIO
      @reply.resultIO << e.message if @reply.resultIO.length == 0
      @reply.append e.resultIO if e.resultIO
    else
      logger.error "Exception rescued in #{request.path}:"
      logger.error e.message
      logger.error e.backtrace
      @reply.debugIO << e.message
      @reply.debugIO << e.backtrace[0..5].join("\n")
      @reply.resultIO << e.message if @reply.resultIO.length == 0
    end
    
    @reply.exitcode = e.respond_to?('exit_code') ? e.exit_code : 1
    render :json => @reply, :status => status
  end
end
