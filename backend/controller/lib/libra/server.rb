require 'libra/helper'
require 'right_aws'
require 'json'
require 'pp'

module Libra
  class Server
    extend Helper

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

      return server_match
    end

    # Returns a list of all the servers that respond
    def self.find_all
      servers = []

      rpc_exec('libra') do |client|
        client.echo(:msg => "ping") do |response|
          servers << response[:senderid] if rsuccess(response)
        end
      end

      return servers
    end
  end
end
