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
        when 'debug', 'alter', 'delete', 'add', 'remove', 'force', 'list'
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
      logger.error "Exception rescued in #{method_name}:"
      logger.error e.message
      logger.error e.backtrace
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

  def embed_cartridge_post
    begin
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
      username = login(data, params, true)
      if username
        action = data['action']
        app_name = data['app_name']

        if !Libra::Util.check_app(app_name)
          render :json => generate_result_json("The supplied application name '#{app_name}' is not allowed", nil, 105), :status => :invalid and return
        end
        
        # Execute a framework cartridge
        Libra.embed_execute(data['cartridge'], action, app_name, username)
        
        if Thread.current[:resultIO] && !Thread.current[:resultIO].string.empty?
          message = Thread.current[:resultIO].string
        else
          message = "Success"
        end

        render :json => generate_result_json(message) and return
      else
        render_unauthorized and return
      end
    rescue Exception => e
      render_error(e, 'cartridge_post') and return
    end
  end

  def cartridge_post
    begin
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
      username = login(data, params, true)
      if username
        server_alias = nil
        action = data['action']
        app_name = data['app_name']
        cartridge = data['cartridge'] # may be nil except for configure
        node_profile = data['node_profile'] if data['node_profile']
        server_alias = data['server_alias'] if data['server_alias']

        # 
        # Confirm application name is valid
        # 
        if !Libra::Util.check_app(app_name)
          render :json => generate_result_json("The supplied application name '#{app_name}' is not allowed", nil, 105), :status => :invalid and return
        end
        
        # Execute a framework cartridge
        app_info = Libra.execute(cartridge, action, app_name, username, node_profile, server_alias)
          
        json_data = nil
        
        message = nil
        if Thread.current[:resultIO] && !Thread.current[:resultIO].string.empty?
          message = Thread.current[:resultIO].string
        end
        if action == 'configure'
          message = "Successfully created application: #{app_name}" if !message
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

          json_data = JSON.generate({:health_check_path => page, :uuid => app_info['uuid']})
        elsif action == 'deconfigure'
          message = "Successfully destroyed application: #{app_name}" if !message
        elsif !message
          message = 'Success'
        end
  
        render :json => generate_result_json(message, json_data) and return
      else
        render_unauthorized and return
      end
    rescue Exception => e
      render_error(e, 'cartridge_post') and return
    end
  end
  
  def user_info_post
    begin      
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
  
      # Check if user already exists
      username = login(data, params, true)
      if username
        user = Libra::User.find(username)
        if user
          user_info = {
              :rhlogin => user.rhlogin,
              :uuid => user.uuid,
              :namespace => user.namespace,
              :ssh_key => user.ssh,
              :rhc_domain => Libra.c[:libra_domain]
              }
          app_info = {}
          
          user.apps.each do |appname, app|
              app_info[appname] = {
                  :framework => app['framework'],
                  :creation_time => app['creation_time'],
                  :uuid => app['uuid'],
                  :embedded => app['embedded'],
                  :aliases => app['aliases']
              }
          end
          
          json_data = JSON.generate({:user_info => user_info,
             :app_info => app_info})
          
          render :json => generate_result_json(nil, json_data) and return
        else
          # Return a 404 to denote the user doesn't exist
          render :json => generate_result_json("User does not exist", nil, 99), :status => :not_found and return
        end
      else
        render_unauthorized and return
      end    
    rescue Exception => e
      render_error(e, 'user_info_post') and return
    end
  end
  
  def domain_post
    begin
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
      username = login(data, params)
      if username
        user = Libra::User.find(username)
        ns = data['namespace']
        if !Libra::Util.check_namespace(ns)
          render :json => generate_result_json("The namespace you entered (#{ns}) is not available for use.  Please choose another one.", nil, 106), :status => :invalid and return
        end
        if user
          if data['alter']
            update = false
            if user.ssh != data['ssh']
              update = true
              previous_ssh_key = user.ssh 
              user.ssh=data['ssh']

              # update each node account for this user's applications
              user.apps.each do |appname, app|
                server = Libra::Server.new app['server_identity']
                server.remove_ssh_key(app, previous_ssh_key)
                server.add_ssh_key(app, user.ssh)
              end
            end
            if user.namespace != ns
              user.update_namespace(ns)
            elsif update
              user.update
            end
          elsif data['delete']
            if user.apps.length > 0
              app_info = {}
              user.apps.each do |appname, app|
                  app_info[appname] = {
                      :framework => app['framework'],
                      :creation_time => app['creation_time'],
                      :aliases => app['aliases']
                  }
              end
              render :json => generate_result_json("The namespace you entered (#{ns}) has the following apps created : #{app_info}. \nAll apps need to be destroyed before namespace can be deleted", nil, 106), :status => :invalid and return
            else
              json_data = JSON.generate({
                              :rhlogin => user.rhlogin,
                              :uuid => user.uuid,
                              :rhc_domain => Libra.c[:libra_domain]
                              })
              user.delete
              dyn_retries = 2
              auth_token = Libra::Server.dyn_login(dyn_retries)
              Libra::Server.dyn_delete_txt_record(ns, auth_token, dyn_retries)
              Libra::Server.dyn_publish(auth_token, dyn_retries)
              Libra::Server.dyn_logout(auth_token, dyn_retries)
              render :json => generate_result_json(nil, json_data) and return
            end
          else
            render :json => generate_result_json("User already has a registered namespace.  To modify, use --alter", nil, 97), :status => :conflict and return
          end
        else
          user = Libra::User.create(username, data['ssh'], ns)
        end
      else
        render_unauthorized and return
      end

      json_data = JSON.generate({
                              :rhlogin => user.rhlogin,
                              :uuid => user.uuid,
                              :rhc_domain => Libra.c[:libra_domain]
                              })

      # Just return a 200 success
      render :json => generate_result_json(nil, json_data) and return
    rescue Exception => e
      render_error(e, 'domain_post') and return
    end
  end

  def cart_list_post
    begin
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
      cart_type = data['cart_type']
      if cart_type != 'standalone' and cart_type != 'embedded'
        render :json => generate_result_json("Invalid cartridge types: #{cart_type} specified", nil, 109), :status => :invalid and return
        #TODO handle subsets (Ex: all php)
      end

      carts = Libra::Util.get_cartridges_list(cart_type)
      json_data = JSON.generate({
                              :carts => carts
                              })

      # Just return a 200 success
      render :json => generate_result_json(nil, json_data) and return
    rescue Exception => e
      render_error(e, 'cart_list_post') and return
    end
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

  def user_manage_post
    begin
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
  
      # Check if rhlogin user already exists
      rhlogin_user_name = login(data, params, true)
      if rhlogin_user_name
        rhlogin_user = Libra::User.find(rhlogin_user_name)
        if rhlogin_user
          if data['add']
            if not data['ssh'] or not data['user_name']
              render :json => generate_result_json("Must provide 'user-name' and 'ssh' key for the user", nil, 105), :status => :invalid and return
            end
            rhlogin_user.add_app_ssh_key(data['user_name'], data['ssh'], data['app_name'], data['force'])
          elsif data['remove']
            if not data['user_name']
              render :json => generate_result_json("Must provide 'user-name'", nil, 105), :status => :invalid and return
            end
            rhlogin_user.remove_app_ssh_key(data['user_name'], data['app_name'])
          elsif data['list']
            app_users = rhlogin_user.list_app_users(data['app_name'])
            json_data = JSON.generate({ :app_users => app_users })
            render :json => generate_result_json(nil, json_data) and return
          else
            render :json => generate_result_json("Invalid action, allowed operations: 'add'/'remove'/'list'", nil, 105), :status => :invalid and return
          end
          
          # Just return a 200 success
          render :json => generate_result_json("Success") and return
        else
          # Return a 404 to denote the user doesn't exist
          render :json => generate_result_json("User does not exist", nil, 99), :status => :not_found and return
        end
      else
        render_unauthorized and return
      end    
    rescue Exception => e
      render_error(e, 'user_manage_post') and return
    end
  end
 
end
