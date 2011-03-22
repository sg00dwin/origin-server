require 'libra/exception.rb'
require 'libra/config.rb'
require 'libra/helper.rb'
require 'libra/server.rb'
require 'libra/user.rb'

module Libra
  
  def self.debug(str)
    Libra.c[:debugIO].puts str
  end
  
  #
  # Executes
  #
  def self.execute(framework, action, app_name, rhlogin, password)
    # Lookup the user
    user = User.find(rhlogin)
    
    # Validate registration
    throw :invalid_user_registration unless User.valid_registration?(rhlogin, password)

    # App exists check
    if action == 'configure'
      throw :app_already_exists if user.app_info(app_name)
      user.validate_app_limit
      # Create S3 app entry on configure (one of the first things)
      user.create_app(app_name, framework)
    else
      if action == 'deconfigure'
        Libra.debug "app not found, attempting to remove anyway..." unless user.app_info(app_name)
      else
        throw :app_does_not_exist unless user.app_info(app_name)
      end
    end

    # Find the next available server
    Libra.c[:rpc_opts][:disctimeout] = 1
    Libra.c[:rpc_opts][:timeout] = 2
    server = Server.find_available

    Libra.debug "Node: #{server.name} - #{server.repos} repos" if Libra.c[:rpc_opts][:verbose]

    # Configure the user on this server if necessary
    Libra.c[:rpc_opts][:disctimeout] = 1
    Libra.c[:rpc_opts][:timeout] = 15
    server.create_user(user) if action == 'configure'

    # Configure the app on the server using a framework cartridge
    result = server.execute_direct(framework, action, "#{app_name} #{user.namespace} #{user.uuid}")[0]
    unless result.results[:data][:exitcode] == 0
        Libra.debug result.results[:data][:output]
        throw :node_execution_failure
    end

    # update DNS
    public_ip = server.get_fact_direct('public_ip')
    Libra.debug "PUBLIC IP: #{public_ip}"
    sshfp = server.get_fact_direct('sshfp').split[-1]
    Server.nsupdate_add(app_name, user.namespace, public_ip, sshfp) if action == 'configure'
    Server.nsupdate_del(app_name, user.namespace, public_ip) if action == 'deconfigure'

    # Remove S3 app on deconfigure (one of the last things
    user.delete_app(app_name) if action == 'deconfigure'
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
    Libra.debug "Added EC2 instance #{result[0]}"
  end
end
