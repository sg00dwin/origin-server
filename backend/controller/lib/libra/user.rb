require 'libra/helper'
require 'right_aws'
require 'json'
require 'date'

module Libra
  class User
    attr_reader :username
    attr_accessor :ssh, :email

    def initialize(username, ssh, email)
      @username, @ssh, @email = username, ssh, email
    end

    def self.from_json(json)
      data = JSON.parse(json)
      new(data['username'], data['ssh'], data['email'])
    end

    #
    # Creates a new user, raising an exception
    # if the user already exists.
    #
    def self.create(username, ssh, email)
      throw :user_exists if find(username)
      puts "DEBUG: user.rb:create username:#{username} ssh:#{ssh} email:#{email}" if Libra.c[:rpc_opts][:verbose]
      user = new(username, ssh, email)
      user.update
      return user
    end

    #
    # Finds all registered usernames
    #
    #   User.find_all_usernames
    #
    def self.find_all_usernames
      usernames = []

      # Retrieve the current list of usernames
      Helper.s3.incrementally_list_bucket(Libra.c[:s3_bucket], { 'prefix' => 'user_info'}) do |result|
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
        return User.from_json(Helper.s3.get(Libra.c[:s3_bucket], "user_info/#{username}/user.json")[:object])
      rescue RightAws::AwsError => e
        if e.message =~ /^NoSuchKey/
          return nil
        else
          raise e
        end
      end
    end

    #
    # Updates the user with the current information
    #
    def update
      json = JSON.generate({:username => username, :email => email, :ssh => ssh})
      puts "DEBUG: user.rb:update json:#{json}" if Libra.c[:rpc_opts][:verbose]
      Helper.s3.put(Libra.c[:s3_bucket], "user_info/#{username}/user.json", json)
    end

    #
    # Returns the servers that this user exists on
    #
    def servers
      # Use the cached value if it exists
      unless @servers
        @servers = {}

        # Make the rpc call to check
        Helper.rpc_get_fact("customer_#{username}") do |server, value|
          # Initialize the hash with the server as the key
          # The applications will eventually become the value
          @servers[Server.new(server)] = nil
        end
      end

      return @servers.keys
    end

    #
    # Returns the applications that this user has running
    #
    def apps
      # Use the cached value if it exists
      unless @apps
        @apps = {}
        app_list = Helper.s3.list_bucket(Libra.c[:s3_bucket], 
                  { 'prefix' => "user_info/#{@username}/apps/"})
        app_list.each do |key|
          json = Helper.s3.get(Libra.c[:s3_bucket], key[:key])
          app_name = key[:key].sub("user_info/#{@username}/apps/", "").sub(".json", "")
          @apps[app_name.to_sym] = app_info(app_name)
        end
      end
      @apps
    end
    #
    # Returns a hash of the server -> apps for this user
    #
    def apps_by_server
      # Read in the apps if necessary
      apps unless @apps

      # Return the server -> app structure
      return @servers
    end

    #
    # Create's an S3 cache of the app for easy tracking and verification
    #
    def create_app(app_name, framework,
                    creation_time=DateTime::now().strftime)
      json = JSON.generate({:framework => framework,
                            :creation_time => creation_time})
      Helper.s3.put(Libra.c[:s3_bucket],
                    "user_info/#{@username}/apps/#{app_name}.json", json)
      JSON.parse(json)
    end

    #
    # Delete an S3 cache of an app
    #
    def delete_app(app_name)
      Helper.s3.delete(Libra.c[:s3_bucket],
                        "user_info/#{@username}/apps/#{app_name}.json")
    end

    #
    # Check if an application already exists
    #
    def app_info(app_name)
      return JSON.parse(Helper.s3.get(Libra.c[:s3_bucket],
            "user_info/#{@username}/apps/#{app_name}.json")[:object])
    rescue RightAws::AwsError => e
      if e.message =~ /^NoSuchKey/
        return nil
      else
        raise e
      end
    end
        

    #
    # Clears out any cached data
    #
    def reload
      @servers, @apps = nil
    end

    #
    # Base equality on the username
    #
    def ==(another_user)
      self.username == another_user.username
    end

    #
    # Base sorting on the username
    #
    def <=>(another_user)
      self.username <=> another_user.username
    end
  end
end
