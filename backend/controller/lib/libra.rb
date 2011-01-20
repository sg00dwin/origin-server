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

    # Find the next available server
    server = Server.find_available

    # Configure the user on this server if necessary
    server.create_user(user) unless user.servers.index(server)

    # Configure the app on the server using a framework cartridge
    server.execute(framework, action, app_name, user)
  end

  #
  # Adjusts the capacity of the Libra cluster if
  # necessary
  #
  def self.adjust_capacity
    # Whether or not we need to add another server
    add_server = true

    # Get the initial capacity
    current_servers = Server.find_all
    current_servers.each do |server|
      # If any server is below the threshold,
      # don't add a new server
      if server.repos < c[:repo_threshold]
        add_server = false
        break
      end
    end

    # Add the additional server if needed
    if add_server
      result = Server.create
      puts "Added EC2 instance #{result[0]}"
    end
  end
end
