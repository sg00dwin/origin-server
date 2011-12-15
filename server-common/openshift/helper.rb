require 'rubygems'
require 'mcollective'
require 'aws'

include MCollective::RPC

module OpenShift
  module Helper
    def self.s3
      # Setup the global access configuration
      AWS.config(
        :access_key_id => OpenShift.c[:aws_key],
        :secret_access_key => OpenShift.c[:aws_secret],
        :logger => OpenShift.c[:logger],
        :ssl_ca_file => "/etc/pki/tls/certs/ca-bundle.trust.crt"
      )

      # Return the AMZ connection
      AWS::S3.new
    end

    def self.bucket
      s3.buckets[OpenShift.c[:s3_bucket]]
    end
    
    def self.rpc_options
      # Make a deep copy of the default options
      Marshal::load(Marshal::dump(OpenShift.c[:rpc_opts]))
    end

    #
    # Execute an RPC call for the specified agent.
    # If a server is supplied, only execute for that server.
    #
    def self.rpc_exec(agent, server=nil, forceRediscovery=false, options = rpc_options)
      if server
        # Filter to the specified server
        options[:filter]["identity"] = server
        options[:mcollective_limit_targets] = "1"
      end

      # Setup the rpc client
      rpc_client = rpcclient(agent, :options => options)
      if forceRediscovery
        rpc_client.reset
      end

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
        rpc_client
    end
  end
end
