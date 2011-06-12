require 'rubygems'
require 'rack'
require 'json'
require 'stringio'
require 'openshift'

include Libra

class BrokerController < ApplicationController
  layout nil
  @@outage_notification_file = '/etc/libra/express_outage_notification.txt'
  
  def generate_result_json(result, exit_code=0)      
      json = JSON.generate({
                  :debug => Thread.current[:debugIO] ? Thread.current[:debugIO].string : '',
                  :messages => Thread.current[:messageIO] ? Thread.current[:messageIO].string : '',
                  :result => result,
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
            render :json => generate_result_json("Invalid namespace: #{val}", 106), :status => :invalid and return nil
          end
        when 'rhlogin'
          if !Util.check_rhlogin(val)
            render :json => generate_result_json("Invalid rhlogin: #{val}", 107), :status => :invalid and return nil
          end
        when 'ssh'
          if !(val =~ /\A[A-Za-z0-9\+\/=]+\z/)
            render :json => generate_result_json("Invalid ssh key: #{val}", 108), :status => :invalid and return nil
          end
        when 'debug', 'alter', 'cartlist'
          if !(val =~ /\A(true|false)\z/)
            render :json => generate_result_json("Invalid value for #{key}:#{val} specified", 254), :status => :invalid and return nil
          end
        when 'cartridge'
          if !(val =~ /\A[\w\-\.]+\z/)
            render :json => generate_result_json("Invalid cartridge: #{val} specified", 254), :status => :invalid and return nil
          end
        when 'action', 'app_name'
          if !(val =~ /\A[\w]+\z/) and val.to_s.length < 24
            render :json => generate_result_json("Invalid #{key} specified: #{val}", 105), :status => :invalid and return nil
          end
        else
          render :json => generate_result_json("Unknown json key found: #{key}", 254), :status => :invalid and return nil
      end
    end
    data
  end
  
  def render_unauthorized
    render :json => generate_result_json("Invalid user credentials", 97), :status => :unauthorized
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
    render :json => generate_result_json(e.message, e.respond_to?('exit_code') ? e.exit_code : 254), :status => :internal_server_error
  end

  def cartridge_post
    begin
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      return unless data
      username = Libra::User.login(data['rhlogin'], params['password'])
      if username
        action = data['action']
        app_name = data['app_name']

        if !Libra::Util.check_app(app_name)
          render :json => generate_result_json("The supplied application name is it not allowed", 105), :status => :invalid and return
        end
        # Execute a framework cartridge
        Libra.execute(data['cartridge'], action, app_name, username)
        
        message = 'Success'
        if action == 'configure'
          message = "Successfully created application: #{app_name}"
        elsif action == 'deconfigure'
          message = "Successfully destroyed application: #{app_name}"
        elsif action == 'status'
          message = Thread.current[:resultIO].string
        end
  
        render :json => generate_result_json(message) and return
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
      username = Libra::User.login(data['rhlogin'], params['password'])
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
                  :uuid => app['uuid']
              }
          end
          
          json_data = JSON.generate({:user_info => user_info,
             :app_info => app_info})
          
          render :json => generate_result_json(json_data) and return
        else
          # Return a 404 to denote the user doesn't exist
          render :json => generate_result_json("User does not exist", 99), :status => :not_found and return
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
      username = Libra::User.login(data['rhlogin'], params['password'])                         
      if username
        user = Libra::User.find(username)
        ns = data['namespace']
        if !Libra::Util.check_namespace(ns)
          render :json => generate_result_json("Invalid characters in namespace '#{ns}' found", 106), :status => :invalid and return
        end
        if user
          if data['alter']
            if user.namespace != ns
              #render :json => generate_result_json("You may not change your registered namespace of: #{user.namespace}", 98), :status => :conflict and return
              user.update_namespace(ns)
            end
            user.namespace=ns
            user.ssh=data['ssh']
            user.update

            # update each node account for this user's applications
            user.apps.each do |appname, app|
              server = Libra::Server.new app['server_identity']
              cfgstring = "-c #{app['uuid']} -e #{user.rhlogin} -s #{user.ssh} -a"
              server.execute_direct('li-controller-0.1', 'configure', cfgstring)
            end
          else
            render :json => generate_result_json("User already has a registered namespace.  To modify, use --alter", 97), :status => :conflict and return
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
      render :json => generate_result_json(json_data) and return
    rescue Exception => e
      render_internal_server_error(e, 'domain_post') and return
    end
  end

  def cart_list_post
    begin
      # Parse the incoming data
      data = parse_json_data(params['json_data'])
      cart_info = data['cartlist']
      if cart_info != "true"
        render_unauthorized and return
      end

      carts = Util.get_cartridges
      json_data = JSON.generate({
                              :cartlist => "true",
                              :carts => carts
                              })

      # Just return a 200 success
      render :json => generate_result_json(json_data) and return
    rescue Exception => e
      render_internal_server_error(e, 'cart_list_post') and return
    end
  end

end
