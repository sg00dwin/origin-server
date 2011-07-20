require 'openshift/error_codes.rb'
require 'openshift/exception.rb'
require 'openshift/config.rb'
require 'openshift/helper.rb'
require 'openshift/server.rb'
require 'openshift/streamline.rb'
require 'openshift/streamline_mock.rb'
require 'openshift/user.rb'
require 'openshift/nurture.rb'
require 'openshift/util.rb'

module Libra

  def self.client_debug(str)
    debugIO = Thread.current[:debugIO]
    if debugIO
      debugIO.puts str
    else
      puts str
    end
  end
  
  def self.client_message(str)
    messageIO = Thread.current[:messageIO]
    if messageIO
      messageIO.puts str
    else
      puts str
    end
  end

  def self.client_result(str)
    resultIO = Thread.current[:resultIO]
    if resultIO
      resultIO.puts str
    else
      puts str
    end
  end

  def self.logger_debug(str)
    if defined? Rails
      Rails.logger.debug str
    else
      puts str
    end
  end

  # Execute a cartridge type (embedded)
  def self.embed_execute(framework, action, app_name, rhlogin)
    # get user
    user = User.find(rhlogin)
    if not user
      raise UserException.new(254), "A user with rhlogin '#{rhlogin}' does not have a registered domain.  Be sure to run rhc-create-domain without -a|--alter first.", caller[0..5]
    end

    # process actions

    case action
    when 'configure'
      # create a new app.  Don't expect it to exist
      embed_configure(framework, app_name, user)

    when 'deconfigure'
      # destroy an app.  It must exists, but won't at the end
      # get the app object
      # get the server
      # send the command to the server
      # remove the app object from persistant storage
      embed_deconfigure(framework, app_name, user)

    else
      # send a command to an app.  It must exist and will afterwards
      # get the app object
      # get the server
      # send the command
      app_info = user.app_info(app_name)

      check_app_exists(app_info)

      if not app_info['embedded'] or not app_info['embedded'][framework]
        raise UserException.new(101), "#{framework} is not embedded in '#{app_name}'", caller[0..5]
      end

      server = Server.new(app_info['server_identity'])

      Libra.logger_debug "DEBUG: Performing action '#{action}' on node '#{server.name}'"
      server_execute_direct('embedded/' + framework, action, app_name, user, server, app_info)
    end
  end
  
  # Raise an exception if cartridge type isn't supported
  def check_cartridge_type(cartridge, server, cart_type)
    carts = Util.get_cartridges_list(cart_type, server)
    cart_framework = Util.get_valid_cart_framework(cartridge, cart_type, carts, server)
    if !cart_framework
      if cart_type == 'standalone'
        raise UserException.new(110), "Invalid application type (-t|--type) specified: '#{cartridge}'.  Valid application types are (#{Util.get_cartridge_listing(cart_type, carts, server)}).", caller[0..5]
      else
        raise UserException.new(110), "Invalid type (-e|--embed) specified: '#{cartridge}'.  Valid embedded types are (#{Util.get_cartridge_listing(cart_type, carts, server)}).", caller[0..5]
      end
    end
  end
  
  # Raise an exception if app doesn't exist
  def check_app_exists(app_info)
    if not app_info
      raise UserException.new(101), "An application named '#{app_name}' does not exist", caller[0..5]
    end
  end


  # Execute a cartridge type (standalone)
  def self.execute(framework, action, app_name, rhlogin)
    # get user
    user = User.find(rhlogin)
    if not user
      raise UserException.new(254), "A user with rhlogin '#{rhlogin}' does not have a registered domain.  Be sure to run rhc-create-domain without -a|--alter first.", caller[0..5]
    end

    # process actions

    case action
    when 'configure'
      # create a new app.  Don't expect it to exist
      configure_app(framework, app_name, user)

    when 'deconfigure'
      # destroy an app.  It must exists, but won't at the end
      # get the app object
      # get the server
      # send the command to the server
      # remove the app object from persistant storage
      deconfigure_app(framework, app_name, user)

    else
      # send a command to an app.  It must exist and will afterwards
      # get the app object
      # get the server
      # send the command
      app_info = user.app_info(app_name)
      check_app_exists(app_info)

      server = Server.new(app_info['server_identity'])

      Libra.logger_debug "DEBUG: Performing action '#{action}' on node '#{server.name}'"
      server_execute_direct(framework, action, app_name, user, server, app_info)
    end
  end

  def self.embed_configure(framework, app_name, user)
    raise UserException.new(100), "An application '#{app_name}' does not exist", caller[0..5] unless user.app_info(app_name)

    # Create persistent storage app entry on configure (one of the first things)
    Libra.logger_debug "DEBUG: Adding embedded app info from persistant storage: #{app_name}:#{framework}"
    app_info = user.app_info(app_name)
    app_info['embedded'] = {} unless app_info['embedded']

    if app_info['embedded'][framework]
      raise UserException.new(101), "#{framework} already embedded in '#{app_name}'", caller[0..5]
    end


    server = Server.new(app_info['server_identity'])
      
    check_cartridge_type(framework, server, 'embedded')

    begin
      server_execute_direct('embedded/' + framework, 'configure', app_name, user, server, app_info)
    rescue Exception => e
      begin
        Libra.logger_debug "DEBUG: Failed to embed '#{framework}' in '#{app_name}' for user '#{user.rhlogin}'"
        Libra.client_debug "Failed to embed '#{framework} in '#{app_name}'"
        server_execute_direct('embedded/' + framework, 'deconfigure', app_name, user, server, app_info)        
      ensure
        raise
      end
    end

    # Put the last line of output from the embedded cartridge into s3, should be a connection string or
    # other useful thing
    if Thread.current[:resultIO].string
        app_info['embedded'][framework] = {'info' => Thread.current[:resultIO].string.split("\n")[-1]}
    end
    Libra.client_debug "Embedded app details: #{app_info['embedded'][framework]}"
    user.update_app(app_info, app_name)
  end

  # remove an application from server and persistant storage
  def self.embed_deconfigure(framework, app_name, user)
    # get the application details
    app_info = user.app_info(app_name)

    check_app_exists(app_info)

    if not app_info['embedded'][framework]
      raise UserException.new(101), "#{framework} not embedded in '#{app_name}', try adding it first", caller[0..5]
    end

    # Remove the application and account from the server
    server = Server.new(app_info['server_identity'])
      
    # first, remove the application
    Libra.logger_debug "DEBUG: Deconfiguring embedded application '#{framework}' in application '#{app_name}' on node '#{server.name}'"
    begin
      server_execute_direct('embedded/' + framework, 'deconfigure', app_name, user, server, app_info)
    rescue Exception => e
      if server.has_embedded_app?(app_info, framework)
        raise
      else
        Libra.logger_debug "DEBUG: Embedded application '#{framework}' not found in application '#{app_name}' on node '#{server.name}'.  Continuing with deconfigure."
        Libra.logger_debug "DEBUG: Error from cartridge on deconfigure: #{e.message}"
      end
    end

    Libra.logger_debug "DEBUG: Removing embedded app info from persistant storage: #{app_name}:#{framework}"
    app_info['embedded'].delete(framework)
    user.update_app(app_info, app_name)
  end

  def self.configure_app(framework, app_name, user)
    raise UserException.new(100), "An application named '#{app_name}' in namespace '#{user.namespace}' already exists", caller[0..5] if user.app_info(app_name)
    # Find the next available server
    server = Server.find_available
    
    check_cartridge_type(framework, server, 'standalone')

    Libra.logger_debug "DEBUG: Performing configure on node '#{server.name}'"

    user.validate_app_limit # TODO there is a race condition here if two users get past here before creating the app and updating s3
    # Create S3 app entry on configure (one of the first things)
    app_info  = user.create_app(app_name, framework, server)

    begin
      # Configure the user on this server if necessary
      server.create_account(user, app_info)

      server_execute_direct(framework, 'configure', app_name, user, server, app_info)
      begin
        # update DNS
        public_ip = server.get_fact_direct('public_ip')
        Libra.logger_debug "DEBUG: Public ip being configured '#{public_ip}' to namespace '#{user.namespace}'"
        sshfp = server.get_fact_direct('sshfp').split[-1]
        Server.create_app_dns_entries(app_name, user.namespace, public_ip, sshfp)
      rescue Exception => e
        begin
          Libra.logger_debug "DEBUG: Failed to register dns entry for app '#{app_name}' and user '#{user.rhlogin}' on node '#{server.name}'"
          Libra.client_debug "Failed to register dns entry for: '#{app_name}'"
        ensure
          raise
        end
      end
    rescue Exception => e
      begin
        Libra.logger_debug "DEBUG: Failed to create application '#{app_name}' for user '#{user.rhlogin}' on node '#{server.name}'"
        Libra.client_debug "Failed to create application: '#{app_name}'"
        server_execute_direct(framework, 'deconfigure', app_name, user, server, app_info)
        Libra.logger_debug "DEBUG: Removing app account from server node: #{app_info.pretty_inspect}"
        server.delete_account(app_info['uuid'])
        Libra.logger_debug "DEBUG: Removing app info from persistant storage: #{app_name}"
        user.delete_app(app_name)
      ensure
        raise
      end
    end
  end

  # remove an application from server and persistant storage
  def self.deconfigure_app(framework, app_name, user)
    # get the application details
    app_info = user.app_info(app_name)
    check_app_exists(app_info)
    
    # Remove the application and account from the server
    server = Server.new(app_info['server_identity'])
      
    # first, remove the application
    Libra.logger_debug "DEBUG: Deconfiguring app '#{app_name}' on node '#{server.name}'"
    begin
      server = server_execute_direct(framework, 'deconfigure', app_name, user, server, app_info)
    rescue Exception => e
      if server.has_app?(app_info, app_name)
        raise
      else
        Libra.logger_debug "DEBUG: Application '#{app_name}' not found on node #{server.name}.  Continuing with deconfigure."
        Libra.logger_debug "DEBUG: Error from cartridge on deconfigure: #{e.message}"
      end
    end

    # then remove the account

    # remove the node account from the server node.
    begin
      Libra.logger_debug "DEBUG: Removing app account from server node: #{app_info.pretty_inspect}"
      server.delete_account(app_info['uuid'])
    rescue Exception => e
      Libra.logger_debug "WARNING: Error removing account '#{app_info['uuid']}' from node '#{app_info['server_identity']}' with message: #{e.message}"
      #TODO check if the user account is still there and raise exception if it is or even better roll this in with deconfigure app
    end

    # remove the DNS entries
    Libra.logger_debug "DEBUG: Public ip being deconfigured from namespace '#{user.namespace}'"
    Server.delete_app_dns_entries(app_name, user.namespace)

    # remove the app record from the user object
    # Remove S3 app on deconfigure (one of the last things)
    Libra.logger_debug "DEBUG: Removing app info from persistant storage: #{app_name}"
    user.delete_app(app_name)

  end

  def self.server_execute_direct(framework, action, app_name, user, server, app_info)
    # Execute the action on the server using a framework cartridge
    Nurture.application(user.rhlogin, user.uuid, app_name, user.namespace, framework, action, app_info['uuid'])
    result = server.execute_direct(framework, action, "#{app_name} #{user.namespace} #{app_info['uuid']}")[0]
    if (result && defined? result.results)
      output = result.results[:data][:output]
      exitcode = result.results[:data][:exitcode]
      if action == 'status'
        if exitcode == 0
          Libra.client_result output
        else
          Libra.client_result "Application '#{app_name}' is either stopped or inaccessible"
        end
      else
        server.log_result_output(output, exitcode)
        if exitcode != 0
          Libra.client_debug "Cartridge return code: " + exitcode.to_s
          raise NodeException.new(143), "Node execution failure (invalid exit code from node).  If the problem persists please contact Red Hat support.", caller[0..5]
        end
      end
    else
      server_identity = action != 'configure' ? Server.find_app(app_info, app_name) : nil
      if server_identity && app_info['server_identity'] != server_identity
        Libra.logger_debug "DEBUG: Changing server identity of '#{app_name}' from '#{app_info['server_identity']}' to '#{server_identity}'"
        app_info['server_identity'] = server_identity
          
        server = Server.new(app_info['server_identity'])
          
        public_ip = server.get_fact_direct('public_ip')
        sshfp = server.get_fact_direct('sshfp').split[-1]
          
        dyn_retries = 2
          
        Libra.logger_debug "DEBUG: Changing public ip of '#{app_name}' to '#{public_ip}'"
        auth_token = Server.dyn_login(dyn_retries)
        # Cleanup the previous records 
        Server.dyn_delete_sshfp_record(app_name, user.namespace, auth_token, dyn_retries)            
        Server.dyn_delete_a_record(app_name, user.namespace, auth_token, dyn_retries)

        # add the new entries          
        Server.dyn_create_a_record(app_name, user.namespace, public_ip, sshfp, auth_token, dyn_retries)
        Server.dyn_create_sshfp_record(app_name, user.namespace, sshfp, auth_token, dyn_retries)
        Server.dyn_publish(auth_token, dyn_retries)
        Server.dyn_logout(auth_token, dyn_retries)
        
        # update s3
        user.update_app(app_info, app_name)
        
        # retry
        return server_execute_direct(framework, action, app_name, user, server, app_info)
      else
        raise NodeException.new(143), "Node execution failure (error getting result from node).  If the problem persists please contact Red Hat support.", caller[0..5]
      end
    end
    return server
  end

  #
  # Adjusts the capacity of the Libra cluster if
  # necessary
  #
  def self.adjust_capacity
    # Get the initial capacity
    current_servers = Server.find_all
    current_servers.each do |server|
      # If any server is below the threshold,
      # don't add a new server
      if server.repos < c[:repo_threshold]
        return
      end
    end

    # Add the additional server if needed
    result = Server.create
    Libra.logger_debug "DEBUG: Added EC2 instance #{result[0]}"
  end
end
