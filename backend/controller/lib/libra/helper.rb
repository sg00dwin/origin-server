require 'rubygems'
require 'mcollective'
require 'right_aws'
require 'right_http_connection'

include MCollective::RPC

module Libra
  module Helper
    def self.s3
      # This will verify the Amazon SSL connection
      Rightscale::HttpConnection.params[:ca_file] = "/etc/pki/tls/certs/ca-bundle.trust.crt"
      RightAws::S3Interface.new(Libra.c[:aws_key],
                                Libra.c[:aws_secret],
                                params = {:logger => Libra.c[:logger]})
    end

    #
    # Return the value of the MCollective response
    # for both a single result and a multiple result
    # structure
    #
    def self.rvalue(response)
      result = nil

      if response[:body]
        result = response[:body][:data][:value]
      elsif response[:data]
        result = response[:data][:value]
      end

      return result
    end

    def self.rsuccess(response)
      response[:body][:statuscode].to_i == 0
    end

    #
    # Returns the fact value from the specified server.
    # Yields to the supplied block if there is a non-nil
    # value for the fact.
    #
    def self.rpc_get_fact(fact, server)
      result = nil

      User.rpc_exec_on_server('rpcutil', server) do |client|
        client.get_fact(:fact => fact) do |response|
          result = rvalue(response)

          # Only yield to the block if there is a value
          yield result if block_given? and result
        end
      end

      return result
    end

    #
    # Yields to a supplied block with each server that
    # has the specified fact, providing the server name
    # and the fact value
    #
    def self.rpc_get_fact(fact)
      rpc_exec('rpcutil') do |client|
        client.get_fact(:fact => fact) do |response|
          next unless Integer(response[:body][:statuscode]) == 0

          # Yield the server and the value to the block
          result = rvalue(response)
          yield response[:senderid], result if result
        end
      end
    end

    #
    # Execute an RPC call for the specified agent.
    # If a server is supplied, only execute for that server.
    #
    def self.rpc_exec(agent, server=nil)
      # Use the passed in base options or parse them
      options = Libra.c[:rpc_opts]

      if server
        # Filter to the specified server
        options[:filter]["identity"] = server
        options[:mcollective_limit_targets] = "1"
      end

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
