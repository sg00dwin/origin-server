require 'rubygems'
require 'mcollective'
require 'aws'
require 'right_http_connection'

include MCollective::RPC

module Libra
  module Helper
    def self.ec2
      # This will verify the Amazon SSL connection
      Rightscale::HttpConnection.params[:ca_file] = "/etc/pki/tls/certs/ca-bundle.trust.crt"
      # Note - might need to look at setting :multi_thread => false
      Aws::Ec2.new(Libra.c[:aws_key],
                   Libra.c[:aws_secret],
                   params = {:logger => Libra.c[:logger]})
    end

    def self.s3
      # This will verify the Amazon SSL connection
      Rightscale::HttpConnection.params[:ca_file] = "/etc/pki/tls/certs/ca-bundle.trust.crt"
      # Note - might need to look at setting :multi_thread => false
      Aws::S3Interface.new(Libra.c[:aws_key],
                           Libra.c[:aws_secret],
                           params = {:logger => Libra.c[:logger]})
    end

    def self.rpc_options
      # Make a deep copy of the default options
      Marshal::load(Marshal::dump(Libra.c[:rpc_opts]))
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

      result
    end

    def self.rsuccess(response)
      response[:body][:statuscode].to_i == 0
    end

    #
    # Returns the fact value from the specified server.
    # Yields to the supplied block if there is a non-nil
    # value for the fact.
    #
    def self.rpc_get_fact(fact, server=nil, forceRediscovery=false)
      result = nil

      Libra.logger_debug("DEBUG: rpc_get_fact: fact=#{fact}")
      rpc_exec('rpcutil', server, forceRediscovery) do |client|
        client.get_fact(:fact => fact) do |response|
          next unless Integer(response[:body][:statuscode]) == 0

          # Yield the server and the value to the block
          result = rvalue(response)
          yield response[:senderid], result if result
        end
      end

      result
    end

    #
    # Given a known fact and node, get a single fact directly.
    # This is significantly faster then the get_facts method
    # If multiple nodes of the same name exist, it will pick just one
    #
    def self.rpc_get_fact_direct(fact, node)
        options = rpc_options

        rpc_client = rpcclient("rpcutil", :options => options)
        begin
          result = rpc_client.custom_request('get_fact', {:fact => fact}, node, {'identity' => node})[0]
          if (result && defined? result.results)  
            value = result.results[:data][:value]
          else
            raise NodeException.new(143), "Node execution failure (error getting fact).  If the problem persists please contact Red Hat support.", caller[0..5]
          end
        ensure
          rpc_client.disconnect
        end

        return value
    end

    #
    # Execute an RPC call for the specified agent.
    # If a server is supplied, only execute for that server.
    #
    def self.rpc_exec(agent, server=nil, forceRediscovery=false)
      options = rpc_options

      if server
        Libra.logger_debug("DEBUG: rpc_exec: Filtering rpc_exec to server #{server}")
        # Filter to the specified server
        options[:filter]["identity"] = server
        options[:mcollective_limit_targets] = "1"
      end

      # Setup the rpc client
      rpc_client = rpcclient(agent, :options => options)
      if forceRediscovery
        rpc_client.reset
      end
      Libra.logger_debug("DEBUG: rpc_exec: rpc_client=#{rpc_client}")

      # Execute a block and make sure we disconnect the client
      begin
        result = yield rpc_client
      ensure
        rpc_client.disconnect
      end

      result
    end

    #
    # Execute direct rpc call directly against a node
    # If more then one node exists, just pick one
    def self.rpc_exec_direct(agent)
        options = rpc_options
        rpc_client = rpcclient(agent, :options => options)
        Libra.logger_debug("DEBUG: rpc_exec_direct: rpc_client=#{rpc_client}")
        rpc_client
    end
  end
end
