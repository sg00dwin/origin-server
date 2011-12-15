require 'aws'
require 'json'
require 'date'
require 'pp'

module OpenShift
  class User
    # Include the correct streamline implementation
    if defined?(Rails) and Rails.configuration.integrated
      include Streamline
    else
      include StreamlineMock
    end

    attr_reader :rhlogin, :password
    attr_accessor :ssh, :namespace, :uuid, :system_ssh_keys, :env_vars, :email_address, :ssh_keys

    def initialize(rhlogin, ssh, system_ssh_keys, env_vars, namespace, uuid, password=nil, ticket=nil, ssh_keys={})
      @rhlogin, @ssh, @system_ssh_keys, @env_vars, @namespace, @uuid, @password, @ticket, @ssh_keys = rhlogin, ssh, system_ssh_keys, env_vars, namespace, uuid, password, ticket, ssh_keys
      @roles = []
    end

    def self.from_json(json)
      data = JSON.parse(json)
      new(data['rhlogin'], data['ssh'], data['system_ssh_keys'], data['env_vars'], data['namespace'], data['uuid'], data['password'], data['ticket'], data['ssh_keys'])
    end
    
    #
    # Finds all registered rhlogins
    #
    #   User.find_all_rhlogins
    #
    def self.find_all_rhlogins
      rhlogins = []

      # Retrieve the current list of rhlogins
      get_users_s3.each do |result|
        if result.key =~ /\/user.json$/
          rhlogins << File.basename(File.dirname(result.key))
        end
      end
      rhlogins
    end

    #
    # Finds a registered rhlogin user.
    #
    #   User.find('test_user')
    #
    def self.find(rhlogin)
      result = get_user_s3(rhlogin)
      return User.from_json(result.read) if result.exists?
    end

    #
    # Updates the rhlogin user with the current information
    #
    def update
      data = {:rhlogin => rhlogin, :namespace => namespace, :ssh => ssh, :uuid => uuid}
      data[:system_ssh_keys] = system_ssh_keys if system_ssh_keys
      data[:env_vars] = env_vars if env_vars
      data[:ssh_keys] = ssh_keys if ssh_keys

      json = JSON.generate(data)
      get_user_s3.write(json)
    end
    
    def update_all
      update
      apps.each do |app_name, app|
        update_app(app, app_name)
      end
    end


    #
    # Returns the applications that this user has running
    #
    def apps
      # Use the cached value if it exists
      unless @apps
        @apps = {}
        get_apps_s3.each do |result|
          json = result.read
          app_name = File.basename(result.key, '.json') unless result.key.end_with?('/')
          if app_name
            @apps[app_name] = app_info(app_name)
          end
        end
      end
      @apps
    end

    #
    # Returns all the user S3 JSON objects
    #
    def self.get_users_s3
      Helper.bucket.objects.with_prefix('user_info')
    end
    
    #
    # Returns the S3 user json object
    #
    def self.get_user_s3(rhlogin)
      Helper.bucket.objects["user_info/#{rhlogin}/user.json"]
    end

    #
    # Returns the S3 user json object
    #
    def get_user_s3
      Helper.bucket.objects["user_info/#{@rhlogin}/user.json"]
    end

    #
    # Returns the application S3 json object
    #
    def get_apps_s3
      Helper.bucket.objects.with_prefix("user_info/#{@rhlogin}/apps/")
    end

    #
    # Returns the application S3 json object
    #
    def get_app_s3(app_name)
      Helper.bucket.objects["user_info/#{@rhlogin}/apps/#{app_name}.json"]
    end
    
    #
    # Updates the S3 cache of the app
    #
    def update_app(app, app_name)
      json = JSON.generate(app)
      get_app_s3(app_name).write(json)
    end

    #
    # Delete an S3 cache of an app
    #
    def delete_app(app_name)
      result = get_app_s3(app_name)
      result.delete if result.exists?
    end

    #
    # Check if an application already exists
    #
    def app_info(app_name)
      result = get_app_s3(app_name)
      return JSON.parse(result.read) if result.exists?
    end

    #
    # Clears out any cached data
    #
    def reload
      @apps = nil
      ##@servers = nil
    end

    #
    # Base equality on the rhlogin
    #
    def ==(another_user)
      self.rhlogin == another_user.rhlogin
    end

    #
    # Base sorting on the rhlogin
    #
    def <=>(another_user)
      self.rhlogin <=> another_user.rhlogin
    end
  end
end
