require 'libra/helper'
require 'right_aws'
require 'json'
require 'pp'

module Libra
  class User
    extend Helper
    private_class_method :new
    attr_reader :username, :ssh, :email

    def initialize(username, ssh, email)
      @username, @ssh, @email = username, ssh, email
    end

    def initialize(json)
      JSON.parse(json).each_pair {|key, value| instance_variable_set("@#{key}", value)}
    end

    #
    # Creates a new user
    #
    def create(username, ssh, email)
      json = JSON.generate({:username => username, :email => email, :ssh => ssh})
      s3.put('libra', "user_info/#{username}.json", json)
      return new(json)
    end

    #
    # Finds all registered usernames
    #
    #   User.find_all_usernames
    #
    def self.find_all_usernames
      usernames = []

      # Retrieve the current list of usernames
      s3.incrementally_list_bucket('libra', { 'prefix' => 'user_info'}) do |result|
        result[:contents].each do |bucket|
          usernames << File.basename(bucket[:key], ".json")
        end
      end

      return usernames
    end

    #
    # Finds a registered user.
    #
    #   User.find('test_user')
    #
    def self.find(username)
      begin
        return new(s3.get('libra', "user_info/#{name}.json")[:object])
      rescue RightAws::AwsError => e
        if e.message =~ /^NoSuchKey/
          return nil
        else
          raise e
        end
      end
    end

    #
    # Returns the servers that this user exists on
    #
    def servers
      # Use the cached value if it exists
      unless @servers
        @servers = {}

        # Make the rpc call to check
        User.rpc_exec('rpcutil') do |client|
          client.get_fact(:fact => "customer_#{username}").each do |resp|
            User.rvalue(resp) { |value| @servers[resp[:sender]] = nil }
          end
        end
      end

      return @servers.keys
    end

    def apps
      # Use the cached value if it exists
      unless @apps
        servers.each do |server|
          User.rpc_exec_on_server('rpcutil', server) do |client|
            client.get_fact(:fact => "git_#{username}").each do |resp|
              User.rvalue(resp) do |value|
                # Split the string of apps into an array
                @servers[server] = value.split(%r{,\s*}).collect do |path|
                  # Parse out just the app name
                  File.basename(path, ".git")
                end
              end
            end
          end
        end

        # Cache a unique, sorted list of all the apps
        @apps = @servers.values.flatten.uniq.sort
      end

      return @apps
    end

    def apps_by_server
      # Read in the apps if necessary
      apps unless @apps

      # Return the server -> app structure
      return @servers
    end

    #
    # Clears out any cached data at the instance level
    #
    def reload
      @servers, @apps = nil
    end
  end
end
