require 'libra/server.rb'
require 'libra/user.rb'
require 'libra/helper.rb'
require 'libra/exception.rb'
require 'libra/config.rb'

module Libra
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
end
