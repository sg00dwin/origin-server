require 'rubygems'
require 'rack'
require 'json'
require 'stringio'
require 'openshift'
require 'openssl'                                                                                                                                                                                              
require 'digest/sha2'
require 'base64'

include Libra

class BrokerController < ApplicationController
  BROKER_VERSION    = "1.1.1"
  BROKER_CAPABILITY = %w(namespace rhlogin ssh app_uuid debug alter cartridge cart_type action app_name api)


  layout nil
  @@outage_notification_file = '/etc/libra/express_outage_notification.txt'
  @client_api = "0.0.0"
  
  def generate_result_json(result, data=nil, exit_code=0)      
      json = JSON.generate({
                  :api => Libra::API::API_VERSION,
                  :api_c => Libra::API::API_CAPABILITY,
                  :broker => BROKER_VERSION,
                  :broker_c => BROKER_CAPABILITY,
                  :debug => Thread.current[:debugIO] ? Thread.current[:debugIO].string : '',
                  :messages => Thread.current[:messageIO] ? Thread.current[:messageIO].string : '',
                  :result => result,
                  :data => data,
                  :exit_code => exit_code
                  })
      json
  end
  
  def check_outage_notification    
    if File.exists?(@@outage_notification_file)
      file = File.open(@@outage_notification_file, "r")
      details = nil
      begin
        details = file.read
      ensure
        file.close
      end
      if details
        Libra.client_message details
      end
    end
  end
  
  def parse_json_data(json_data)
    thread = Thread.current # Need to find a better way to do this.  Object structure for request would work.  Perhaps there is something more elegant built into rails?
    thread[:debugIO] = StringIO.new
    thread[:resultIO] = StringIO.new
    thread[:messageIO] = StringIO.new
    thread[:errorIO] = StringIO.new
    thread[:appInfoIO] = nil
    check_outage_notification
    data = JSON.parse(json_data)
    if (data['debug'])
      Libra.c[:rpc_opts][:verbose] = true
    end

    data['node_profile']='std' unless data['node_profile']

    # Validate known json vars.  Error on unknown vars.
    data.each do |key, val|
      case key
        when 'namespace'
          if !(val =~ /\A[A-Za-z0-9]+\z/)
            render :json => generate_result_json("Invalid namespace: #{val}", nil, 106), :status => :invalid and return nil
          end
        when 'rhlogin'
          if !Util.check_rhlogin(val)
            render :json => generate_result_json("Invalid rhlogin: #{val}", nil, 107), :status => :invalid and return nil
          end
        when 'user_name'
          if !Util.check_user(val)
            render :json => generate_result_json("Invalid username: #{val}", nil, 106), :status => :invalid and return nil
          end
        when 'ssh'
          if !(val =~ /\A[A-Za-z0-9\+\/=]+\z/)
            render :json => generate_result_json("Invalid ssh key: #{val}", nil, 108), :status => :invalid and return nil
          end
        when 'app_uuid'
          if !(val =~ /\A[a-f0-9]+\z/)
            render :json => generate_result_json("Invalid application uuid: #{val}", nil, 1), :status => :invalid and return nil
          end
        when 'node_profile'
          if !(val =~ /\A(jumbo|exlarge|large|micro|std)\z/)
            render :json => generate_result_json("Invalid Profile: #{val}.  Must be: (jumbo|exlarge|large|micro|std)", nil, 1), :status => :invalid and return nil
          end
        when 'debug', 'alter', 'delete'
          if val != true && val != false && !(val =~ /\A(true|false)\z/)
            render :json => generate_result_json("Invalid value for #{key} specified: #{val}", nil, 1), :status => :invalid and return nil
          end
        when 'cartridge'
          if !(val =~ /\A[\w\-\.]+\z/)
            render :json => generate_result_json("Invalid cartridge specified: #{val}", nil, 1), :status => :invalid and return nil
          end
        when 'api'
          if !(val =~ /\A\d+\.\d+\.\d+\z/)
            render :json => generate_result_json("Invalid API value specified: #{val}", nil, 112), :status => :invalid and return nil
          end
          @client_api = val
        when 'cart_type'
          if !(val =~ /\A[\w\-\.]+\z/)
            render :json => generate_result_json("Invalid cart_type specified: #{val}", nil, 109), :status => :invalid and return nil
          end
        when 'action'
          if !(val =~ /\A[\w\-\.]+\z/)
            render :json => generate_result_json("Invalid #{key} specified: #{val}", nil, 111), :status => :invalid and return nil
          end
        when 'app_name'
          if !(val =~ /\A[\w]+\z/)
            render :json => generate_result_json("Invalid #{key} specified: #{val}", nil, 105), :status => :invalid and return nil
          end
        when 'server_alias'
          if !(val =~ /\A[\w\-\.]+\z/) or (val =~ /rhcloud.com$/)
            render :json => generate_result_json("Invalid ServerAlias specified: #{val}", nil, 105), :status => :invalid and return nil
          end
        else
          render :json => generate_result_json("Unknown json key found: #{key}", nil, 1), :status => :invalid and return nil
      end
    end
    data
  end
  
  def render_unauthorized
    render :json => generate_result_json("Invalid user credentials", nil, 97), :status => :unauthorized
  end
  
  def render_error(e, method_name)
    status = :internal_server_error
    message = nil
    if !(e.is_a? Libra::LibraException) 
      Rails.logger.error "Exception rescued in #{method_name}:"
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      # TODO should we leave this?  Everything that gets in here is unknown and users can tell us about it.  But will mean impl details showing up on the client.
      Libra.client_debug e.message
      Libra.client_debug e.backtrace
    elsif (e.is_a? Libra::StreamlineException)
      logger.error "StreamlineException rescued in #{method_name}:"
      logger.error e.message
      logger.error e.backtrace
      message = "An error occurred communicating with the user repository.  If the problem persists please contact Red Hat support."
    elsif !(e.is_a? Libra::UserException) # User Exceptions just go back to the client
      logger.error "Exception rescued in #{method_name}:"
      logger.error e.message
    elsif (e.is_a? Libra::UserException)
      status = :bad_request
    end
    message = e.message if !message
    if Thread.current[:errorIO] && !Thread.current[:errorIO].string.empty?
      message = Thread.current[:errorIO].string
    end
    render :json => generate_result_json(message, nil, e.respond_to?('exit_code') ? e.exit_code : 1), :status => status
  end
  
  def login(data, params, allow_broker_auth_key=false)
    username = nil
    if allow_broker_auth_key && params['broker_auth_key'] && params['broker_auth_iv']
      encrypted_token = Base64::decode64(params['broker_auth_key'])
      cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
      cipher.decrypt
      cipher.key = OpenSSL::Digest::SHA512.new(Libra.c[:broker_auth_secret]).digest
      private_key = OpenSSL::PKey::RSA.new(File.read('config/keys/private.pem'), Libra.c[:broker_auth_rsa_secret])
      cipher.iv =  private_key.private_decrypt(Base64::decode64(params['broker_auth_iv']))
      json_token = cipher.update(encrypted_token)
      json_token << cipher.final

      token = JSON.parse(json_token)
      username = token['rhlogin']
      user = Libra::User.find(username)
      if user
        app_name = token['app_name']
        app = user.apps[app_name]
        if app
          creation_time = token['creation_time']
          render_unauthorized and return if creation_time != app['creation_time']
        else
          render_unauthorized and return
        end
      else
        render_unauthorized and return
      end
    else
      username = Libra::User.new(data['rhlogin'], nil, nil, nil, nil, nil, params['password'], ticket).login()
    end
    return username
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
end
