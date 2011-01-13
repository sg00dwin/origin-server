require 'rubygems'
require 'mcollective'
require 'pp'

include MCollective::RPC

module Libra
  module Helper

    #
    # Return the value of the MCollective response
    # for both a single result and a multiple result
    # structure
    #
    def rvalue(response)
      if response[:body]
        return response[:body][:data][:value]
      elsif response[:data]
        return response[:data][:value]
      end

      return nil
    end

    #
    # Checks whether a user exists on the specified server
    #
    def rpc_exec(agent, rpc_opts = nil)
      # Use the passed in base options or parse them
      options = rpc_opts || rpcoptions

      # Setup the rpc client
      rpc_client = rpcclient(agent, :options => options)
      rpc_client.progress = false
      rpc_client.timeout = 1

      # Execute a block and make sure we disconnect the client
      begin
        result = yield rpc_client
      ensure
        rpc_client.disconnect
      end

      return result
    end

    #
    # Checks whether a user exists on the specified server
    #
    def rpc_exec_on_server(agent, server, rpc_opts = nil)
      # Use the passed in base options or parse them
      options = rpc_opts || rpcoptions

      # Filter to the specified server
      options[:filter]["identity"] = server
      options[:mcollective_limit_targets] = "1"

      # Setup the rpc client
      rpc_client = rpcclient(agent, :options => options)
      rpc_client.progress = false
      rpc_client.timeout = 1

      # Execute a block and make sure we disconnect the client
      begin
        result = yield rpc_client
      ensure
        rpc_client.disconnect
      end

      return result
    end
  end
end
