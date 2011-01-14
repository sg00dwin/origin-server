require 'rubygems'
require 'mcollective'
require 'right_aws'
require 'right_http_connection'
require 'parseconfig'
require 'pp'

include MCollective::RPC

module Libra
  module Helper
    def s3
      # By default, read aws config from /etc/libra/libra_s3.conf
      unless Libra.aws_key
        config = ParseConfig.new('/etc/libra/libra_s3.conf')
        Libra.aws_key = config.get_value('aws_access_key_id')
        Libra.aws_secret = config.get_value('aws_secret_access_key')
      end

      # This will verify the Amazon SSL connection
      Rightscale::HttpConnection.params[:ca_file] = "/etc/pki/tls/certs/ca-bundle.trust.crt"
      RightAws::S3Interface.new(Libra.aws_key, Libra.aws_secret, params = {:logger => Libra.logger})
    end

    #
    # Return the value of the MCollective response
    # for both a single result and a multiple result
    # structure
    #
    def rvalue(response)
      result = nil

      if response[:body]
        result = response[:body][:data][:value]
      elsif response[:data]
        result = response[:data][:value]
      end

      return result
    end

    def rsuccess(response)
      response[:body][:statuscode].to_i == 0
    end

    #
    # Returns the fact value from the specified server.
    # Yields to the supplied block if there is a non-nil
    # value for the fact.
    #
    def rpc_get_fact(fact, server)
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
    def rpc_get_fact(fact)
      User.rpc_exec('rpcutil') do |client|
        client.get_fact(:fact => fact) do |response|
          next unless Integer(response[:body][:statuscode]) == 0

          # Yield the server and the value to the block
          result = rvalue(response)
          yield response[:senderid], result if result
        end
      end
    end

    #
    # Execute an RPC call for the specified agent on all servers
    #
    def rpc_exec(agent)
      # Use the passed in base options or parse them
      options = Libra.rpc_opts || rpcoptions

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
    # Execute an RPC call for the specified agent on the specified server
    #
    def rpc_exec(agent, server)
      # Use the passed in base options or parse them
      options = Libra.rpc_opts || rpcoptions

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
