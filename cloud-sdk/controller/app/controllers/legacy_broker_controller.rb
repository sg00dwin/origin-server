require 'rubygems'
require 'rack'
require 'json'
require 'stringio'
require 'openssl'                                                                                                                                                                                              
require 'digest/sha2'
require 'base64'
require 'app/lib/auth_service.rb'

class LegacyBrokerController < ApplicationController
  layout nil
  before_filter :validate_request
  before_filter :authenticate, :except => :cart_list_post
  rescue_from Exception, :with => :exception_handler
  
  def user_info_post
    user = CloudUser.find(@login)
    if user
      user_info = user.as_json
      user_info[:rhc_domain] = Rails.application.config.cdk[:domain_suffix]
      app_info = {}
      user.applications.each do |app|
        app_info[app.name] = app.as_json
      end
      
      @reply.data = {:user_info => user_info, :app_info => app_info}.to_json
      render :json => @reply
    else
      # Return a 404 to denote the user doesn't exist
      @reply.result = "User does not exist"
      @reply.code = 99
      
      render :json => @reply, :status => :not_found
    end
  end
  
  def domain_post
    cloud_user = CloudUser.find(@login)
    if @req.alter
      cloud_user.ssh = @req.ssh
      cloud_user.namespace = @req.namespace
    else
      cloud_user = CloudUser.new(@login, @req.ssh, @req.namespace)
    end
        
    if cloud_user.invalid?
      @reply.result = cloud_user.errors.first[1]
      render :json => @reply, :status => :invalid 
      return
    end
        
    cloud_user.save(@reply)
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
      @reply.result = "Invalid cartridge types: #{cart_type} specified"
      @reply.exit_code = 109
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
      
      app = Application.new(user, @req.app_name, nil, @req.node_profile, @req.framework)
      if app.valid?
        app.save
        begin
          app.create
          app.add_ssh_keys
          app.add_env_vars
          app.create_dns
          app.configure_dependencies        
          
          case app.framework_cartridge
            when 'php'
              page = 'health_check.php'
            when 'perl'
              page = 'health_check.pl'
            else
              page = 'health'
          end
        
          @reply.data = {:health_check_path => page, :uuid => app.uuid}.to_json
        rescue
          app.delete_dns
          app.destroy
          app.delete
        end
        @reply.result = @reply.resultIO.string if @reply.resultIO && !@reply.resultIO.string.empty?      
        @reply.result = "Successfully created application: #{app_name}" unless @reply.result      
      else
        @reply.result = app.errors.first[1]
        render :json => @reply, :status => :invalid 
        return
      end
    when 'deconfigure'
      app = Application.find(@login, @req.app_name)
      app.destroy
      
      if app.framework_cartridge == "jenkins"
        user.applications.each do |uapp|
          uapp.remove_cartridge('jenkins-client-1.4') if uapp.name != app.name and uapp.embedded and uapp.embedded.has_key?('jenkins-client-1.4')
        end
      end
      
      app.delete_dns
      app.delete
      @reply.result = "Successfully destroyed application: #{app_name}" unless @reply.result      
    when 'start'
      app = Application.find(@login, @req.app_name)
      app.start
    when 'stop'
      app = Application.find(@login, @req.app_name)
      app.stop
    when 'restart'
      app = Application.find(@login, @req.app_name)
      app.restart
    when 'force-stop'
      app = Application.find(@login, @req.app_name)
      app.force_stop
    when 'reload'
      app = Application.find(@login, @req.app_name)
      app.reload
    when 'status'
      app = Application.find(@login, @req.app_name)
      app.status
    when 'tidy'
      app = Application.find(@login, @req.app_name)
      app.tidy      
    when 'add-alias'
      app = Application.find(@login, @req.app_name)
      app.tidy
    when 'remove-alias'
      app = Application.find(@login, @req.app_name)
      app.tidy      
    else
      #unrecognized command
    end
    @reply.result = 'Success' unless @reply.result
    
    render :json => @reply
  end
  
  def embed_cartridge_post
    case @req.action
    when 'add'
      app = Application.find(@login, @req.app_name)
      app.add_dependency()
    when 'remove'
      app.remove_dependency()      
    when 'start'
      app.start_dependency()      
    when 'stop'
      app.stop_dependency()      
    when 'restart'
      app.restart_dependency()      
    when 'status'
      app.dependency_status()      
    when 'reload'
      app.reload_dependency()      
    end
    
    #add|remove|start|stop|restart|status|reload
    
    # Execute a framework cartridge
    Libra.embed_execute(@req.cartridge, @req.action, @req.app_name, @login)
    @reply.result = @reply.resultIO.string if @reply.resultIO && !@reply.resultIO.string.empty?
    @reply.result = "Success" unless @reply.result
    render :json => @reply
  end
  
  
  
  
  #
  #def nurture_post
  #  begin
  #    # Parse the incoming data
  #    data = parse_json_data(params['json_data'])
  #    return unless data
  #    action = data['action']
  #    app_uuid = data['app_uuid']
  #    Nurture.application_update(action, app_uuid)
  #    Apptegic.application_update(action, app_uuid)
  #
  #    # Just return a 200 success
  #    render :json => generate_result_json("Success") and return
  #    
  #  rescue Exception => e
  #    render_error(e, 'nurture_post') and return
  #  end
  #end
  
  protected
  
  def validate_request
    @reply = LegacyReply.new
    begin
      @req = LegacyRequest.new.from_json(params['json_data'])
      if @req.invalid?
        @reply.attributes=(@req.errors.first[1])
        render :json => @reply, :status => :invalid 
      end
    end
  end
  
  def authenticate
    @login = AuthService.login(request, params, cookies)
    unless @login
      @reply.message, @reply.exit_code = "Invalid user credentials", 97
      render :json => @reply, :status => :unauthorized
    end
  end
  
  def exception_handler(e)
    status = :internal_server_error
    case e
    when AuthServiceException
      logger.error "AuthenticationException rescued in #{request.path}"
      logger.error e.message
      logger.error e.backtrace
      @reply.message = "An error occurred while contacting the authentication service. If the problem persists please contact support."
    when Cloud::Sdk::WorkflowException
      logger.error "WorkflowException rescued in #{request.path}"
      logger.error e.message
      @reply.debug += e.message
      @reply.debug += e.backtrace[0..5].to_s
      @reply.message = e.message unless @reply.message
      status = :bad_request
    when Cloud::Sdk::CdkException
      logger.error "Exception rescued in #{request.path}:"
      logger.error e.message
      logger.error e.backtrace
      @reply.message = "An internal error occurred [code: #{e.code}]. If the problem persists please contact support." unless @reply.message
    else
      logger.error "Exception rescued in #{request.path}:"
      logger.error e.message
      logger.error e.backtrace
      @reply.debug += e.message
      @reply.debug += e.backtrace[0..5].to_s
      @reply.message = e.message unless @reply.message
    end
    
    @reply.exit_code = e.respond_to?('exit_code') ? e.exit_code : 1
    render :json => @reply, :status => status
  end
end