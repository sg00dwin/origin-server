require 'openshift/exception.rb'
require 'openshift/config.rb'
require 'openshift/helper.rb'
require 'openshift/server.rb'
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

  #
  # Executes
  #
  def self.execute(framework, action, app_name, rhlogin)
    # Lookup the user
    user = User.find(rhlogin)

    if user
      # App exists check
      if action == 'configure'
        configure_app(framework, action, app_name, user)
      else
        app_info = user.app_info(app_name)
        if !app_info
          if action == 'deconfigure'
            Libra.client_debug "Application not found, attempting to remove anyway..."
          else
            raise UserException.new(101), "An application named '#{app_name}' does not exist", caller[0..5]
          end
        end
        if app_info
          # Find the next available server
          if app_info['server_identity']
            server = Server.new(app_info['server_identity'])
            if server
              Libra.logger_debug "DEBUG: Performing action '#{action}' on node: #{server.name} - #{server.repos} repos" if Libra.c[:rpc_opts][:verbose]
              server_execute_direct(framework, action, app_name, user, server, app_info)

              if action == 'deconfigure'
                # update DNS
                Libra.logger_debug "DEBUG: Public ip being deconfigured from namespace '#{user.namespace}'"
                Server.delete_app_dns_entries(app_name, user.namespace)
              end
            else
              if action == 'deconfigure'
                Libra.client_debug "Application is registered to an invalid node, still attempting to remove everything else..."
                Libra.logger_debug "DEBUG: Application '#{app_name}' is registered by user '#{rhlogin}(#{app_info['uuid']})' to an invalid node '#{app_info.server_identity}', application will be destroyed but some space may still be consumed for app on the node..."
              else
                raise NodeException.new(142), "The application #{app_name} is registered to an invalid node.  If the problem persists please contact Red Hat support.", caller[0..5]
              end
            end
          elsif action != 'deconfigure'
            raise NodeException.new(254), "The application #{app_name} is registered without a specified node.", caller[0..5]
          end
        end
        if action == 'deconfigure'
          # Remove S3 app on deconfigure (one of the last things)
          user.delete_app(app_name)
        end
      end
    else
      # shouldn't really happen
      raise UserException.new(254), "User '#{rhlogin}' not found", caller[0..5]
    end
  end

  def self.configure_app(framework, action, app_name, user)
    raise UserException.new(100), "An application named '#{app_name}' already exists", caller[0..5] if user.app_info(app_name)
    # Find the next available server
    server = Server.find_available

    Libra.logger_debug "DEBUG: Performing configure on node: #{server.name} - #{server.repos} repos" if Libra.c[:rpc_opts][:verbose]

    user.validate_app_limit # TODO there is a race condition here if two users get past here before creating the app and updating s3
    # Create S3 app entry on configure (one of the first things)
    app_info  = user.create_app(app_name, framework, server)

    begin
      # Configure the user on this server if necessary
      server.create_user(user, app_info) # not cleaned up on failure

      server_execute_direct(framework, action, app_name, user, server, app_info)
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
          server_execute_direct(framework, 'deconfigure', app_name, user, server, app_info)
        ensure
          raise
        end
      end
    rescue Exception => e
      begin
        Libra.logger_debug "DEBUG: Failed to create application '#{app_name}' for user '#{user.rhlogin}' on node '#{server.name}'"
        Libra.client_debug "Failed to create application: '#{app_name}'"
        server_execute_direct(framework, 'deconfigure', app_name, user, server, app_info)        
      ensure
        raise
      end
    end
  end

  def self.server_execute_direct(framework, action, app_name, user, server, app_info)
    # Execute the action on the server using a framework cartridge
    Nurture.application(user.rhlogin, app_info['uuid'], app_name, user.namespace, framework, action)
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
      elsif exitcode != 0
        Libra.client_debug "Cartridge return code: " + exitcode.to_s
        Libra.client_debug "Cartridge output: " + output
        Libra.logger_debug "DEBUG: execute_direct results: " + output
        raise NodeException.new(143), "Node execution failure (invalid exit code from execute direct).  If the problem persists please contact Red Hat support.", caller[0..5]
      end
    else
      raise NodeException.new(143), "Node execution failure (error getting result from execute direct).  If the problem persists please contact Red Hat support.", caller[0..5]
    end
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
