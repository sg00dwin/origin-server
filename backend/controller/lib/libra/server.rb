require 'libra/helper'
require 'right_aws'
require 'json'

module Libra
  class Server
    # Cartridge definitions
    @@C_CONTROLLER = 'li-controller-0.1'

    attr_reader :name, :repos

    def initialize(name, repos)
      @name = name
      @repos = repos.to_i
    end

    def self.create(opts={})
      # Set defaults
      opts[:key_name] ||= Libra.c[:aws_keypair]
      opts[:image_id] ||= Libra.c[:aws_ami]
      opts[:max_count] ||= 1
      opts[:instance_type] ||= "m1.large"

      # Create the instances in EC2, returning
      # an array of the image id's
      Helper.ec2.run_instances(opts[:image_id],
                                        opts[:max_count],
                                        opts[:max_count],
                                        nil,
                                        opts[:key_name],
                                        "",
                                        nil,
                                        opts[:instance_type]).collect do |server|
        server[:aws_instance_id]
      end
    end

    #
    # Returns the preferred available server.
    # Currently this is defined by the server that
    # has the least number of git repos on it.
    #
    def self.find_available
      # Defaults
      server_match, num_repos = nil, -1

      Helper.rpc_get_fact('git_repos') do |server, repos|
        # Initialize the results if needed
        server_match, num_repos = server, repos unless server_match

        # See if this is a better match
        server_match, num_repos = server, repos if num_repos > repos
      end

      return new(server_match, num_repos)
    end

    #
    # Returns a list of all the servers that respond
    #
    def self.find_all
      servers = []

      Helper.rpc_get_fact('git_repos') do |server, repos|
        servers << new(server, repos)
      end

      return servers
    end

    #
    # Configures the user on this server
    #
    def create_user(user)
      # Make the call to configure the user
      execute_internal(@@C_CONTROLLER, 'configure', "-c #{user.username} -e #{user.email} -s #{user.ssh}")
    end

    #
    # Configures the application for this user on this server
    #
    def execute(framework, action, app_name, user)
      # Make the call to configure the application
      execute_internal(framework, action, "#{app_name} #{user.username}")
    end

    #
    # Execute the cartridge and action on this server
    #
    def execute_internal(cartridge, action, args)
      Helper.rpc_exec('libra', name) do |client|
        client.cartridge_do(:cartridge => cartridge,
                            :action => action,
                            :args => args) do |response|
          return_code = response[:body][:data][:exitcode]
          output = response[:body][:data][:output]

          raise ConfigureException, output if return_code != 0
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
