require 'openshift/helper'
require 'openshift/server'
require 'openshift/nurture'
require 'aws'
require 'json'
require 'date'
require 'net/http'
require 'net/https'
require 'pp'

module Libra
  class User
    # Include the correct streamline implementation
    if defined?(Rails) and Rails.configuration.integrated
      include Streamline
    else
      include StreamlineMock
    end

    attr_reader :rhlogin, :password
    attr_accessor :ssh, :namespace, :uuid, :system_ssh_keys, :env_vars, :email_address

    def initialize(rhlogin, ssh, system_ssh_keys, env_vars, namespace, uuid, password=nil, ticket=nil)
      @rhlogin, @ssh, @system_ssh_keys, @env_vars, @namespace, @uuid, @password, @ticket, = rhlogin, ssh, system_ssh_keys, env_vars, namespace, uuid, password, ticket
      @roles = []
    end

    def self.from_json(json)
      data = JSON.parse(json)
      new(data['rhlogin'], data['ssh'], data['system_ssh_keys'], data['env_vars'], data['namespace'], data['uuid'])
    end

    #
    # Creates a new user, raising an exception
    # if the user already exists or invalid chars are found.
    #
    def self.create(rhlogin, ssh, namespace, dyn_retries=2)
      auth_token = nil
      begin
        auth_token = Server.dyn_login(dyn_retries)
        raise UserException.new(107), "Invalid characters in RHlogin '#{rhlogin}' found", caller[0..5] if !Util.check_rhlogin(rhlogin)
        raise UserException.new(102), "A user with RHLogin '#{rhlogin}' already exists", caller[0..5] if find(rhlogin)

        Server.dyn_has_txt_record?(namespace, auth_token, true)

        Libra.client_debug "Creating user entry rhlogin:#{rhlogin} ssh:#{ssh} namespace:#{namespace}" if Libra.c[:rpc_opts][:verbose]

        Server.dyn_create_txt_record(namespace, auth_token, dyn_retries)
        Server.dyn_publish(auth_token, dyn_retries)
        Libra.logger_debug "DEBUG: Attempting to add namespace '#{namespace}' for user '#{rhlogin}'"
        Libra.client_debug "Creating user entry rhlogin:#{rhlogin} ssh:#{ssh} namespace:#{namespace}" if Libra.c[:rpc_opts][:verbose]
        begin
          uuid = Util.gen_small_uuid()
          user = new(rhlogin, ssh, nil, nil, namespace, uuid)
          user.update
          begin
            Nurture.libra_contact(rhlogin, uuid, namespace, 'create')
            Apptegic.libra_contact(rhlogin, uuid, namespace, 'create')
          rescue Exception => e
            Libra.logger_debug "DEBUG: Attempting to delete user '#{rhlogin}' after failing to add nurture contact"
            begin
              user.delete
            ensure
              raise
            end
          end
          return user
        rescue Exception => e
          Libra.logger_debug "DEBUG: Attempting to remove namespace '#{namespace}' after failure to add user '#{rhlogin}'"
          begin
            Server.dyn_delete_txt_record(namespace, auth_token, dyn_retries)
            Server.dyn_publish(auth_token, dyn_retries)
          ensure
            raise
          end
        end
      ensure
        Server.dyn_logout(auth_token, dyn_retries)
      end
    end
    
    #
    # Validates number of apps for a user is below the limit
    #
    def validate_app_limit
      num_apps = apps.length
      Libra.client_debug "Validating application limit #{@rhlogin}: num of apps(#{num_apps.to_s}) must be < app limit(#{Libra.c[:per_user_app_limit]})" if Libra.c[:rpc_opts][:verbose]
      if (num_apps >= Libra.c[:per_user_app_limit])
        raise UserException.new(104), "#{@rhlogin} has already reached the application limit of #{Libra.c[:per_user_app_limit]}", caller[0..5]
      end
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
    # Finds a registered user.
    #
    #   User.find('test_user')
    #
    def self.find(rhlogin)
      result = get_user_s3(rhlogin)
      return User.from_json(result.read) if result.exists?
    end

    #
    # Updates the user with the current information
    #
    def update
      data = {:rhlogin => rhlogin, :namespace => namespace, :ssh => ssh, :uuid => uuid}
      data[:system_ssh_keys] = system_ssh_keys if system_ssh_keys
      data[:env_vars] = env_vars if env_vars

      json = JSON.generate(data)
      Libra.logger_debug "DEBUG: Updating user json:#{json}"
      get_user_s3.write(json)
    end
    
    def update_all
      update
      apps.each do |app_name, app|
        update_app(app, app_name)
      end
    end
    
    #
    # Add an ssh key to each of the apps
    #
    def add_ssh_key_to_apps(app_name, ssh_key)
      apps.each do |appname, app|
        if appname != app_name
          server = Libra::Server.new app['server_identity']
          server.add_ssh_key(app, ssh_key)
        end
      end
    end
    
    #
    # Remove an ssh key from each of the apps
    #
    def remove_ssh_key_from_apps(app_name, ssh_key)
      apps.each do |appname, app|
        if appname != app_name
          server = Libra::Server.new app['server_identity']
          server.remove_ssh_key(app, ssh_key)
        end
      end
    end
    
    #
    # Add an env var to each of the apps
    #
    def add_env_var_to_apps(app_name, key, value)
      apps.each do |appname, app|
        if appname != app_name
          server = Libra::Server.new app['server_identity']
          server.add_env_var(app, key, value)
        end
      end
    end
    
    #
    # Remove an env var from each of the apps
    #
    def remove_env_var_from_apps(app_name, key)
      apps.each do |appname, app|
        if appname != app_name
          server = Libra::Server.new app['server_identity']
          server.remove_env_var(app, key)
        end
      end
    end

    #
    # Add an ssh key for the specified app to access all other apps owned by the user
    #
    def set_system_ssh_key(app_name, ssh_key)
      @system_ssh_keys = {} unless @system_ssh_keys
      @system_ssh_keys[app_name] = ssh_key
      update
      add_ssh_key_to_apps(app_name, ssh_key)
    end
    
    #
    # Remove an ssh key from the authorized keys of this user's apps
    #
    def remove_system_ssh_key(app_name)
      if system_ssh_keys && system_ssh_keys.key?(app_name)
        ssh_key = system_ssh_keys[app_name]
        system_ssh_keys.delete(app_name)
        update
        remove_ssh_key_from_apps(app_name, ssh_key)
      end
    end
    
    #
    # Add an env var to user and all other apps owned by the user
    #
    def set_env_var(app_name, key, value)
      @env_vars = {} unless @env_vars
      @env_vars[key] = value
      update
      add_env_var_to_apps(app_name, key, value)
    end
    
    #
    # Remove an env var from the user and this user's apps
    #
    def remove_env_var(app_name, key)
      if env_vars && env_vars.key?(key)
        env_vars.delete(key)
        update
        remove_env_var_from_apps(app_name, key)
      end
    end

    #
    # Add a broker authorized key
    #
    def set_broker_auth_key(app_name, app)
      server = Libra::Server.new app['server_identity']
      server.set_broker_auth_key(app_name, app, rhlogin)
    end
    
    #
    # Remove a broker authorized key
    #
    def remove_broker_auth_key(app_name, app)
      server = Libra::Server.new app['server_identity']
      server.remove_broker_auth_key(app_name, app)
    end
    
    #
    # Updates the user's namespace for txt and full app domains
    #
    def update_namespace(new_namespace, dyn_retries=2)
      old_namespace = namespace
      auth_token = Server.dyn_login(dyn_retries)
      begin
        Server.dyn_has_txt_record?(new_namespace, auth_token, true) 
        Server.dyn_create_txt_record(new_namespace, auth_token, dyn_retries)
        Server.dyn_delete_txt_record(@namespace, auth_token, dyn_retries)
        apps.each do |app_name, app_info|
          Libra.logger_debug "DEBUG: Updating namespaces for app: #{app_name}"
          server = Server.new(app_info['server_identity'])
          
          server.recreate_app_dns_entries(app_name, @namespace, new_namespace, auth_token, dyn_retries)
        end
        
        update_namespace_failures = []
        apps.each do |app_name, app_info|
          begin
            Libra.logger_debug "DEBUG: Updating namespace for app: #{app_name}"
            server = Server.new(app_info['server_identity'])
            result = server.execute_direct(app_info['framework'], 'update_namespace', "#{app_name} #{new_namespace} #{@namespace} #{app_info['uuid']}")[0]
            if (result && defined? result.results && result.results.has_key?(:data))            
              exitcode = result.results[:data][:exitcode]
              output = result.results[:data][:output]
              server.log_result_output(output, exitcode, self, app_name, app_info)
              if exitcode != 0
                update_namespace_failures.push(app_name)                
              end
            else
              update_namespace_failures.push(app_name)
            end
          rescue Exception => e
            Libra.client_debug "Exception caught updating namespace #{e.message}"
            Libra.logger_debug "DEBUG: Exception caught updating namespace #{e.message}"
            Libra.logger_debug e.backtrace
            update_namespace_failures.push(app_name)
          end
        end
        
        raise NodeException.new(143), "Error updating apps: #{update_namespace_failures.pretty_inspect.chomp}.  Updates will not be completed until all apps can be updated successfully.  If the problem persists please contact Red Hat support.", caller[0..5] if !update_namespace_failures.empty?
        
        Nurture.libra_contact(rhlogin, uuid, new_namespace, 'update')
        Apptegic.libra_contact(rhlogin, uuid, new_namespace, 'update')
        
        Server.dyn_publish(auth_token, dyn_retries)
      rescue LibraException => e
        raise
      rescue Exception => e
        Libra.client_debug "Exception caught updating namespace: #{e.message}"
        Libra.logger_debug "DEBUG: Exception caught updating namespace: #{e.message}"
        Libra.logger_debug e.backtrace
        raise LibraException.new(1), "An error occurred updating the namespace.  If the problem persists please contact Red Hat support.", caller[0..5]
      ensure
        Server.dyn_logout(auth_token, dyn_retries)
      end
      @namespace = new_namespace
      update
      apps.each do |app_name, app_info|
        if app_info.has_key?('embedded')
          embedded = app_info['embedded']
          embedded.each_key do |framework|
            if embedded[framework].has_key?('info')
              info = embedded[framework]['info']
              info.gsub!(/-#{old_namespace}.#{Libra.c[:libra_domain]}/, "-#{new_namespace}.#{Libra.c[:libra_domain]}")
              embedded[framework]['info'] = info
            end
          end
          update_app(app_info, app_name) if update
        end
      end
    end
    
    #
    # Moves an app from one server to another
    #    
    def move_app(app_name, app_info, new_server)
      Libra.logger_debug "DEBUG: Changing server identity of '#{app_name}' from '#{app_info['server_identity']}' to '#{new_server.name}'"
      app_info['server_identity'] = new_server.name

      dyn_retries = 2
      auth_token = Server.dyn_login(dyn_retries)
      new_server.recreate_app_dns_entries(app_name, namespace, namespace, auth_token, dyn_retries)
      Server.dyn_publish(auth_token, dyn_retries)
      Server.dyn_logout(auth_token, dyn_retries)
      
      # update s3
      update_app(app_info, app_name)
    end
    
    #
    # Deletes the user with the current information
    #    
    def delete
      Libra.client_debug "Deleting user: #{rhlogin}" if Libra.c[:rpc_opts][:verbose]
      result = get_user_s3
      result.delete if result.exists?
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
          else
            Libra.logger_debug "DEBUG: App not found '#{app_name}' for user '#{rhlogin}'"
          end
        end
      end
      @apps
    end

    #
    # Create's an S3 cache of the app for easy tracking and verification
    #
    def create_app(app_name, framework, server,
                   creation_time=DateTime::now().strftime,
                   uuid=nil
                   )
      h = {
        'framework' => framework,
        'server_identity' => server.name,
        'creation_time' => creation_time,
        'uuid' => uuid || Util.gen_small_uuid
      }
      update_app(h, app_name)
      h
    end
    
    def add_alias(app, app_name, server_alias)
      app['aliases'] = [] if !app['aliases']
      aliases = app['aliases']
      unless aliases.include?(server_alias)
        aliases.push(server_alias)
        update_app(app, app_name)
        return true
      end
      return false
    end
    
    def remove_alias(app, app_name, server_alias)
      if app['aliases'] && app['aliases'].delete(server_alias)
        update_app(app, app_name)
        return true
      end
      return false
    end
    
    def has_alias(app, server_alias)
      return app['aliases'] && app['aliases'].include?(server_alias)
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
