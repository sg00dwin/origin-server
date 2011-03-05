require 'libra/exception.rb'
require 'libra/config.rb'
require 'libra/helper.rb'
require 'libra/server.rb'
require 'libra/user.rb'

module Libra
  #
  # Executes
  #
  def self.execute(framework, action, app_name, username)
    # Lookup the user
    user = User.find(username)

    # App exists check
    if action == 'configure'
      throw :app_already_exists if user.app_info(app_name)
      Server.validate_app_limit(user)
    else
      if action == 'deconfigure'
        puts "app not found, attempting to remove anyway..." unless user.app_info(app_name)
      else
        throw :app_does_not_exist unless user.app_info(app_name)
      end
    end        

    # Find the next available server
    Libra.c[:rpc_opts][:disctimeout] = 1
    Libra.c[:rpc_opts][:timeout] = 2
    server = Server.find_available

    puts "Node: #{server.name} - #{server.repos} repos" if Libra.c[:rpc_opts][:verbose]

    # Configure the user on this server if necessary
    Libra.c[:rpc_opts][:disctimeout] = 1
    Libra.c[:rpc_opts][:timeout] = 15
    server.create_user(user)

    # Configure the app on the server using a framework cartridge
    #server.execute(framework, action, app_name, user)
    result = server.execute_direct(framework, action, "#{app_name} #{user.username} #{user.uuid}")[0]
    unless result.results[:data][:exitcode] == 0
        puts result.results[:data][:output]
        throw :node_execution_failure
    end

    # update DNS
    #public_ip = Helper.rpc_get_fact_direct('public_ip', server.name)
    public_ip = server.get_fact_direct('public_ip')
    sshfp = server.get_fact_direct('sshfp').split[-1]
    Server.nsupdate_add(app_name, user.username, public_ip, sshfp) if action == 'configure'
    Server.nsupdate_del(app_name, user.username, public_ip) if action == 'deconfigure'
    
    user.create_app(app_name, framework) if action == 'configure'
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
    puts "Added EC2 instance #{result[0]}"
  end
end
