require 'openshift/api.rb'
require 'openshift/error_codes.rb'
require 'openshift/exception.rb'
require 'openshift/config.rb'
require 'openshift/helper.rb'
require 'openshift/server.rb'
require 'openshift/streamline.rb'
require 'openshift/streamline_mock.rb'
require 'openshift/user.rb'
require 'openshift/apptegic.rb'
require 'openshift/nurture.rb'
require 'openshift/util.rb'

module Libra

  def self.client_debug(str)
    debug_io = Thread.current[:debugIO]
    if debug_io
      debug_io.puts str
    else
      puts str
    end
  end
  
  def self.client_message(str)
    message_io = Thread.current[:messageIO]
    if message_io
      message_io.puts str
    else
      puts str
    end
  end

  def self.client_result(str)
    result_io = Thread.current[:resultIO]
    if result_io
      result_io.puts str
    else
      puts str
    end
  end
  
  def self.client_error(str)
    error_io = Thread.current[:errorIO]
    if error_io
      error_io.puts str
    else
      puts str
    end
  end

  def self.add_app_info(str)
    Thread.current[:appInfoIO] = StringIO.new unless Thread.current[:appInfoIO]
    app_info_io = Thread.current[:appInfoIO]
    app_info_io.puts str
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
    user = get_user(rhlogin)

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

      check_app_exists(app_info, app_name)

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
  def check_app_exists(app_info, app_name)
    if not app_info
      raise UserException.new(101), "An application named '#{app_name}' does not exist", caller[0..5]
    end
  end


  # Execute a cartridge type (standalone)
  def self.execute(framework, action, app_name, rhlogin, node_profile)
    user = get_user(rhlogin)

    # process actions

    if action == 'configure'
      # create a new app.  Don't expect it to exist
      configure_app(framework, app_name, user, node_profile)
    else
      app_info = user.app_info(app_name)
      check_app_exists(app_info, app_name)

      server = Server.new(app_info['server_identity'])

      Libra.logger_debug "DEBUG: Performing action '#{action}' on node '#{server.name}'"
      if action == 'deconfigure'
        deconfigure_app(app_info, app_name, user, server)
      else
        server_execute_direct(app_info['framework'], action, app_name, user, server, app_info)
      end
    end
  end
  
  # Move an app
  def self.execute_move(app_name, rhlogin, new_server_identity=nil, node_profile='std')
    user = get_user(rhlogin)

    app_info = user.app_info(app_name)
    check_app_exists(app_info, app_name)

    if new_server_identity
      new_server = Server.new(new_server_identity)
    else
      new_server = Server.find_available(node_profile)
    end

    old_server = Server.new(app_info['server_identity'])

    server_execute_direct(app_info['framework'], 'stop', app_name, user, old_server, app_info)

    new_server.create_account(user, app_info)

    `eval \`ssh-agent\`; ssh-add /var/www/libra/broker/config/keys/rsync_id_rsa; ssh -o StrictHostKeyChecking=no -A root@#{old_server.get_fact_direct('ipaddress')} "rsync -az --exclude '.env/OPENSHIFT_INTERNAL_IP' -e 'ssh -o StrictHostKeyChecking=no' /var/lib/libra/#{app_info['uuid']}/ root@#{new_server.get_fact_direct('ipaddress')}:/var/lib/libra/#{app_info['uuid']}/"`

    server_execute_direct(app_info['framework'], 'deploy_httpd_proxy', app_name, user, new_server, app_info, false)

    server_execute_direct(app_info['framework'], 'start', app_name, user, new_server, app_info, false)

    user.move_app(app_name, app_info, new_server)

    deconfigure_app_from_node(app_info, app_name, user, old_server, false)
  end
  
  def self.get_user(rhlogin)
    user = User.find(rhlogin)
    if not user
      raise UserException.new(254), "A user with rhlogin '#{rhlogin}' does not have a registered domain.  Be sure to run rhc-create-domain without -a|--alter first.", caller[0..5]
    end
    return user
  end

  def self.embed_configure(framework, app_name, user) 
    check_app_exists(user.app_info(app_name), app_name)

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
    if Thread.current[:appInfoIO]
      app_info['embedded'][framework] = {'info' => Thread.current[:appInfoIO].string}
    else
      app_info['embedded'][framework] = {'info' => ''}
    end
    Libra.client_debug "Embedded app details: #{app_info['embedded'][framework]}"
    user.update_app(app_info, app_name)
  end

  # remove an application from server and persistant storage
  def self.embed_deconfigure(framework, app_name, user)
    # get the application details
    app_info = user.app_info(app_name)

    check_app_exists(app_info, app_name)

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

  def self.configure_app(framework, app_name, user, node_profile)
    raise UserException.new(100), "An application named '#{app_name}' in namespace '#{user.namespace}' already exists", caller[0..5] if user.app_info(app_name)
    
    #TODO would be nice to move the unique flag to be specified on the cart
    type = Libra::Util.get_cart_framework(framework)
    if type == 'jenkins'
      user.apps.each do |appname, app|
        if Libra::Util.get_cart_framework(app['framework']) == 'jenkins'
          raise UserException.new(115), "A jenkins application named '#{appname}' in namespace '#{user.namespace}' already exists.  You can only have 1 jenkins application per account.", caller[0..5]
        end
      end
    end
    
    # Find the next available server
    server = Server.find_available(node_profile)
    
    check_cartridge_type(framework, server, 'standalone')

    Libra.logger_debug "DEBUG: Performing configure on node '#{server.name}'"

    user.validate_app_limit # TODO there is a race condition here if two users get past here before creating the app and updating s3
    # Create S3 app entry on configure (one of the first things)
    app_info  = user.create_app(app_name, framework, server)

    begin
      # Configure the user on this server if necessary
      server.create_account(user, app_info)

      server_execute_direct(framework, 'preconfigure', app_name, user, server, app_info)
      server_execute_direct(framework, 'configure', app_name, user, server, app_info)
      
      # Add any secondary ssh keys
      user.system_ssh_keys.each_value do |ssh_key|
        server.add_ssh_key(app_info, ssh_key)
      end if user.system_ssh_keys
      
      # Add any secondary env vars
      user.env_vars.each do |key, value|
        server.add_env_var(app_info, key, value)
      end if user.env_vars
      
      begin
        # update DNS
        server.create_app_dns_entries(app_name, user.namespace)
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
  def self.deconfigure_app(app_info, app_name, user, server)
    deconfigure_app_from_node(app_info, app_name, user, server)

    # remove the DNS entries
    Libra.logger_debug "DEBUG: Public ip being deconfigured from namespace '#{user.namespace}'"
    server.delete_app_dns_entries(app_name, user.namespace)

    # remove the app record from the user object
    # Remove S3 app on deconfigure (one of the last things)
    Libra.logger_debug "DEBUG: Removing app info from persistant storage: #{app_name}"
    user.delete_app(app_name)

  end
  
  def self.deconfigure_app_from_node(app_info, app_name, user, server, allow_move=true)
    # first, remove the application
    begin
      server = server_execute_direct(app_info['framework'], 'deconfigure', app_name, user, server, app_info, allow_move)
    rescue Exception => e
      if server.has_app?(app_info, app_name)
        raise
      else
        Libra.logger_debug "DEBUG: Application '#{app_name}' not found on node #{server.name}."
        Libra.logger_debug "DEBUG: Error from cartridge on deconfigure: #{e.message}"
      end
    end

    # then remove the account

    # remove the node account from the server node.
    begin
      Libra.logger_debug "DEBUG: Removing app account from server node: #{app_info.pretty_inspect}"
      server.delete_account(app_info['uuid'])
    rescue Exception => e
      Libra.logger_debug "WARNING: Error removing account '#{app_info['uuid']}' from node '#{server.name}' with message: #{e.message}"
      #TODO check if the user account is still there and raise exception if it is or even better roll this in with deconfigure app
    end
  end

  def self.server_execute_direct(framework, action, app_name, user, server, app_info, allow_move=true)
    # Execute the action on the server using a framework cartridge
    Nurture.application(user.rhlogin, user.uuid, app_name, user.namespace, framework, action, app_info['uuid'])
    Apptegic.application(user.rhlogin, user.uuid, app_name, user.namespace, framework, action, app_info['uuid'])
    result = server.execute_direct(framework, action, "#{app_name} #{user.namespace} #{app_info['uuid']}")[0]
    if (result && defined? result.results && result.results.has_key?(:data))
      output = result.results[:data][:output]
      exitcode = result.results[:data][:exitcode]
      if action == 'status'
        if exitcode == 0
          Libra.client_result output
        else
          Libra.client_result "Application '#{app_name}' is either stopped or inaccessible"
        end
      else
        server.log_result_output(output, exitcode, user, app_name, app_info)
        if exitcode != 0
          Libra.client_debug "Cartridge return code: " + exitcode.to_s
          raise NodeException.new(143), "Node execution failure (invalid exit code from node).  If the problem persists please contact Red Hat support.", caller[0..5]
        end
      end
    else
      server_identity = action != 'configure' ? Server.find_app(app_info, app_name) : nil
      if allow_move && server_identity && app_info['server_identity'] != server_identity
        server = Server.new(server_identity)
        user.move_app(app_name, app_info, server)
        # retry
        return server_execute_direct(framework, action, app_name, user, server, app_info)
      else
        raise NodeException.new(143), "Node execution failure (error getting result from node).  If the problem persists please contact Red Hat support.", caller[0..5]
      end
    end
    return server
  end
end
