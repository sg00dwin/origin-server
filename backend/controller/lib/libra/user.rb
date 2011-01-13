require 'libra/helper'
require 'pp'

module Libra
  class UserHelper
    extend Helper

    #
    # Checks whether a user exists on any server.  Returns
    # an array of the resulting servers.
    #
    #   UserHelper.exists('myuser')
    #
    def self.exists(user, rpc_opts=nil)
      result = []

      # Make the rpc call to check
      rpc_exec('rpcutil', rpc_opts) do |client|
        client.get_fact(:fact => "customer_#{user}").each do |resp|
            result << resp[:sender] unless rvalue(resp).nil?
        end
      end

      return result
    end

    #
    # Checks whether a user exists on the specified server.
    # The rpc_opts argument will override the default MCollective
    # client rpc options that are parsed from the command line.
    #
    #   UserHelper.exists_on_server('myserver', 'myuser')
    #
    def self.exists_on_server(server, user, rpc_opts=nil)
      exists = false

      # Make the rpc call to check
      rpc_exec_on_server('rpcutil', server, rpc_opts) do |client|
        client.get_fact(:fact => "customer_#{user}") do |resp|
            exists = !rvalue(resp).nil?
        end
      end

      return exists
    end
  end
end
