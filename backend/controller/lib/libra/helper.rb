require 'rubygems'
require 'mcollective'
require 'right_aws'
require 'right_http_connection'
require 'pp'

include MCollective::RPC

module Libra
  module Helper
    def s3
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

      # Only yield to the block if there is a result
      # and a block was supplied
      yield result if block_given? and result

      return result
    end

    #
    # Checks whether a user exists on the specified server
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
    # Checks whether a user exists on the specified server
    #
    def rpc_exec_on_server(agent, server)
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
