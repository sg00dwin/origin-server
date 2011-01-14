require 'libra/helper'
require 'right_aws'
require 'json'
require 'pp'

module Libra
  class Server
    extend Helper

    # Cartridge definitions
    @@C_CONTROLLER = 'li-controller-0.1'

    attr_reader :name

    def initialize(name)
      @name = name
    end

    #
    # Returns the preferred available server.
    # Currently this is defined by the server that
    # has the least number of git repos on it.
    #
    def self.find_available
      # Defaults
      server_match, num_repos = nil, -1

      rpc_get_fact('git_repos') do |server, repos|
        # Initialize the results if needed
        server_match, num_repos = server, repos unless server_match

        # See if this is a better match
        server_match, num_repos = server, repos if num_repos > repos
      end

      return new(server_match)
    end

    # Returns a list of all the servers that respond
    def self.find_all
      servers = []

      rpc_exec('libra') do |client|
        client.echo(:msg => "ping") do |response|
          servers << new(response[:senderid]) if rsuccess(response)
        end
      end

      return servers
    end

    #
    # Configures the user on this server
    #
    def configure(user)
      # Make the call to configure the user
      execute(@@C_CONTROLLER, 'configure', "-c #{user.username} -e #{user.email} -s #{user.ssh}")
    end

    #
    # Configures the application for this user on this server
    #
    def configure_app(framework, app_name, user)
      # Make the call to configure the application
      execute(framework, 'configure', "#{app_name} #{user.username}")
    end

    #
    #
    # Anything below this point is private
    #
    #
    private

    #
    # Execute the cartridge and action on this server
    #
    def execute(cartridge, action, args)
      Server.rpc_exec('libra', name) do |client|
        client.cartridge_do(:cartridge => cartridge,
                            :action => action,
                            :args => args) do |response|
          return_code = response[:body][:data][:exitcode]
          output = response[:body][:data][:output]

          raise ConfigException, output if return_code != 0
        end
      end
    end

    #
    # Base equality on the server name
    #
    def ==(another_server)
      self.name == another_server.name
    end

    #
    # Base sorting on the server name
    #
    def <=>(another_server)
      self.name <=> another_server.name
    end
  end
end
