require 'rubygems'
require 'rack'
require 'json'
require 'stringio'
require 'openssl'                                                                                                                                                                                              
require 'digest/sha2'
require 'base64'

class LegacyBrokerController < ApplicationController
  layout nil
  before_filter :validate_request, :authenticate
  rescue_from Exception, :with => exception_handler
  
  def domain_post
    cloud_user = CloudUser.find(@login)
    if @req.alter
      cloud_user.ssh = @req.ssh
      cloud_user.namespace = @req.namespace
    else
      cloud_user = CloudUser.new(@login, @req.ssh, @req.namespace)
    end
        
    if cloud_user.invalid?
      @reply.attributes=(cloud_user.errors.first[1])
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
  
  def cartridge_post
    app_info = Libra.execute(@req.cartridge, @req.action, @req.app_name, @login, @req.node_profile, @req.server_alias, @reply)
    @reply.result = @reply.resultIO.string if @reply.resultIO && !@reply.resultIO.string.empty?
      
    case @req.action
    when "configure"
      @reply.result = "Successfully created application: #{app_name}" unless @reply.result
      
      # TODO would like to move this further down.  Perhaps store cart=>page as the cartlist fact?
      type = Libra::Util.get_cart_framework(cartridge)
      case type
        when 'php'
          page = 'health_check.php'
        when 'perl'
          page = 'health_check.pl'
        else
          page = 'health'
      end

      @reply.data = JSON.generate({:health_check_path => page, :uuid => app_info['uuid']})
    when "deconfigure"
      @reply.result = "Successfully destroyed application: #{app_name}" unless @reply.result
    else
      @reply.result = 'Success' unless @reply.result
    end
    
    render :json => @reply
  end
  
  def embed_cartridge_post
    # Execute a framework cartridge
    Libra.embed_execute(@req.cartridge, @req.action, @req.app_name, @login)
    @reply.result = @reply.resultIO.string if @reply.resultIO && !@reply.resultIO.string.empty?
    @reply.result = "Success" unless @reply.result
    render :json => @reply
  end
  
  def user_info_post
    user = CloudUser.find(@login)
    if user
      user_info = user.attributes
      app_info = {}
      user.applications.each do |appname, app|
        app_info[appname] = app.attributes
      end
      
      @reply.data = JSON.generate({:user_info => user_info, :app_info => app_info})
      render :json => @reply
    else
      # Return a 404 to denote the user doesn't exist
      @reply.result = "User does not exist"
      @reply.code = 99
      
      render :json => @reply, :status => :not_found
    end
  end
  
  def cart_list_post
    cart_type = @req.cart_type
    if cart_type != 'standalone' and cart_type != 'embedded'
      @reply.result = "Invalid cartridge types: #{cart_type} specified"
      @reply.exit_code = 109
      
      render :json => @reply, :status => :invalid
      return
    end

    carts = Libra::Util.get_cartridges_list(cart_type)
    @reply.data = JSON.generate { :carts => carts }
    # Just return a 200 success
    
    render :json => @reply
  end
  
  def nurture_post
    begin
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
      action = data['action']
      app_uuid = data['app_uuid']
      Nurture.application_update(action, app_uuid)
      Apptegic.application_update(action, app_uuid)
  
      # Just return a 200 success
      render :json => generate_result_json("Success") and return
      
    rescue Exception => e
      render_error(e, 'nurture_post') and return
    end
  end
  
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
    when Cloud::SDK::WorkflowException
      logger.error "WorkflowException rescued in #{request.path}"
      logger.error e.message
      @reply.debug e.message
      @reply.debug e.backtrace[0..5]
      @reply.message = e.message unless @reply.message
      status = :bad_request
    when Cloud::SDK::CdkException
      logger.error "Exception rescued in #{request.path}:"
      logger.error e.message
      logger.error e.backtrace
      @reply.message = "An internal error occurred [code: #{e.code}]. If the problem persists please contact support." unless @reply.message
    else
      logger.error "Exception rescued in #{request.path}:"
      logger.error e.message
      logger.error e.backtrace
      @reply.debug e.message
      @reply.debug e.backtrace[0..5]
      @reply.message = e.message unless @reply.message
    end
    
    @reply.exit_code = e.respond_to?('exit_code') ? e.exit_code : 1
    render :json => @reply, :status => status
  end
end
