require 'rubygems'
require 'rack'
require 'json'
require 'stringio'
require 'openshift'

include Libra

class BrokerController < ApplicationController
  BROKER_VERSION    = "1.1.1"
  BROKER_CAPABILITY = %w(namespace rhlogin ssh app_uuid dubug alter cartridge cart_type action app_name api)


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
    check_outage_notification
    data = JSON.parse(json_data)
    if (data['debug'])
      Libra.c[:rpc_opts][:verbose] = true
    end

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
        when 'ssh'
          if !(val =~ /\A[A-Za-z0-9\+\/=]+\z/)
            render :json => generate_result_json("Invalid ssh key: #{val}", nil, 108), :status => :invalid and return nil
          end
        when 'app_uuid'
          if !(val =~ /\A[a-f0-9]+\z/)
            render :json => generate_result_json("Invalid application uuid: #{val}", nil, 254), :status => :invalid and return nil
          end
        when 'debug', 'alter'
          if !(val =~ /\A(true|false)\z/)
            render :json => generate_result_json("Invalid value for #{key}:#{val} specified", nil, 254), :status => :invalid and return nil
          end
        when 'cartridge'
          if !(val =~ /\A[\w\-\.]+\z/)
            render :json => generate_result_json("Invalid cartridge: #{val} specified", nil, 254), :status => :invalid and return nil
          end
        when 'api'
          if !(val =~ /\A[0-9]+\.[0-9]+\.[0-9]+\z/)
            render :json => generate_result_json("Invalid API value: #{val} specified", nil, 109), :status => :invalid and return nil
          end
          @client_api = val
        when 'cart_type'
          if !(val =~ /\A[\w\-\.]+\z/)
            render :json => generate_result_json("Invalid cart_type: #{val} specified", nil, 109), :status => :invalid and return nil
          end
        when 'action'
          if !(val =~ /\A[\w\-\.]+\z/) and val.to_s.length < 24
            render :json => generate_result_json("Invalid #{key} specified: #{val}", nil, 105), :status => :invalid and return nil
          end
        when 'app_name'
          if !(val =~ /\A[\w]+\z/) and val.to_s.length < 24
            render :json => generate_result_json("Invalid #{key} specified: #{val}", nil, 105), :status => :invalid and return nil
          end
        else
          render :json => generate_result_json("Unknown json key found: #{key}", nil, 254), :status => :invalid and return nil
      end
    end
    data
  end
  
  def render_unauthorized
    render :json => generate_result_json("Invalid user credentials", nil, 97), :status => :unauthorized
  end
  
  def render_internal_server_error(e, method_name)      
    if !(e.is_a? Libra::LibraException) 
      logger.error "Exception rescued in #{method_name}:"
      logger.error e.message
      logger.error e.backtrace
      # TODO should we leave this?  Everything that gets in here is unknown and users can tell us about it.  But will mean impl details showing up on the client.
      Libra.client_debug e.message
      Libra.client_debug e.backtrace
    elsif !(e.is_a? Libra::UserException) # User Exceptions just go back to the client
      logger.error "Exception rescued in #{method_name}:"
      logger.error e.message
    end
    render :json => generate_result_json(e.message, nil, e.respond_to?('exit_code') ? e.exit_code : 254), :status => :internal_server_error
  end

  def embed_cartridge_post
    begin
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
      username = Libra::User.new(data['rhlogin'], nil, nil, nil, params['password'], ticket).login()
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
      render_internal_server_error(e, 'cartridge_post') and return
    end
  end

  def cartridge_post
    begin
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
      username = Libra::User.new(data['rhlogin'], nil, nil, nil, params['password'], ticket).login()
      if username
        action = data['action']
        app_name = data['app_name']
        cartridge = data['cartridge']

        if !Libra::Util.check_app(app_name)
          render :json => generate_result_json("The supplied application name '#{app_name}' is not allowed", nil, 105), :status => :invalid and return
        end
        
        # Execute a framework cartridge
        Libra.execute(cartridge, action, app_name, username)
          
        json_data = nil
        
        message = 'Success'
        if action == 'configure'
          message = "Successfully created application: #{app_name}"
          # TODO would like to move this future down.  Perhaps store cart=>page as the cartlist fact?
          type = Libra::Util.get_cart_framework(cartridge)
          case type
            when 'php'
              page = 'health_check.php'
            when 'perl'
              page = 'health_check.pl'
            else
              page = 'health'
          end
          json_data = JSON.generate({:health_check_path => page})
        elsif action == 'deconfigure'
          message = "Successfully destroyed application: #{app_name}"
        elsif action == 'status' || (Thread.current[:resultIO] && !Thread.current[:resultIO].string.empty?)
          message = Thread.current[:resultIO].string 
        end
  
        render :json => generate_result_json(message, json_data) and return
      else
        render_unauthorized and return
      end
    rescue Exception => e
      render_internal_server_error(e, 'cartridge_post') and return
    end
  end
  
  def user_info_post
    begin      
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
  
      # Check if user already exists
      username = Libra::User.new(data['rhlogin'], nil, nil, nil, params['password'], ticket).login()
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
                  :embedded => app['embedded']
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
      render_internal_server_error(e, 'user_info_post') and return
    end
  end
  
  def domain_post
    begin
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
      username = Libra::User.new(data['rhlogin'], nil, nil, nil, params['password'], ticket).login()
      if username
        user = Libra::User.find(username)
        ns = data['namespace']
        if !Libra::Util.check_namespace(ns)
          render :json => generate_result_json("Invalid characters in namespace '#{ns}' found", nil, 106), :status => :invalid and return
        end
        if user
          if data['alter']
            if user.namespace != ns
              user.update_namespace(ns)
            end
            user.namespace=ns
            user.ssh=data['ssh']
            user.update

            # update each node account for this user's applications
            user.apps.each do |appname, app|
              server = Libra::Server.new app['server_identity']
              cfgstring = "-c #{app['uuid']} -e #{user.rhlogin} -s #{user.ssh} -a"
              result = server.execute_direct('li-controller-0.1', 'configure', cfgstring)
              server.handle_controller_result(result)
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
                              :uuid => user.uuid
                              })

      # Just return a 200 success
      render :json => generate_result_json(nil, json_data) and return
    rescue Exception => e
      render_internal_server_error(e, 'domain_post') and return
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
      render_internal_server_error(e, 'cart_list_post') and return
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
      render_internal_server_error(e, 'nurture_post') and return
    end
  end  

end
