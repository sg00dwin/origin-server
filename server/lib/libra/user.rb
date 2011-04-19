require 'libra/helper'
require 'libra/server'
require 'libra/nurture'
require 'aws'
require 'json'
require 'date'
require 'net/http'
require 'net/https'

def gen_small_uuid()
    # Put config option for rhlogin here so we can ignore uuid for dev environments
    %x[/usr/bin/uuidgen].gsub('-', '').strip
end

module Libra
  class User
    attr_reader :rhlogin
    attr_accessor :ssh, :namespace, :uuid

    def initialize(rhlogin, ssh, namespace, uuid)
      @rhlogin, @ssh, @namespace, @uuid = rhlogin, ssh, namespace, uuid
    end

    def self.from_json(json)
      data = JSON.parse(json)
      if data['uuid']
        new(data['rhlogin'], data['ssh'], data['namespace'], data['uuid'])
      else
        uuid = gen_small_uuid()
        user = new(data['rhlogin'], data['ssh'], data['namespace'], uuid)
        user.update
        user
      end
    end

    #
    # Creates a new user, raising an exception
    # if the user already exists or invalid chars are found.
    #
    def self.create(rhlogin, ssh, namespace)

      auth_token = nil
      begin
        if Libra.c[:use_dynect_dns]
          auth_token = Server.dyn_login
        end
        raise UserException.new(107), "Invalid chars in RHlogin '#{rhlogin}' found", caller[0..5] if !Util.check_rhlogin(rhlogin)
        raise UserException.new(102), "A user with RHLogin '#{rhlogin}' already exists", caller[0..5] if find(rhlogin)
  
        raise UserException.new(106), "Invalid chars in namespace '#{namespace}' found", caller[0..5] if !Util.check_namespace(namespace)
        has_txt_record = Libra.c[:use_dynect_dns] ? Server.dyn_has_txt_record?(namespace, auth_token) : Server.has_dns_txt?(namespace)
        raise UserException.new(103), "A namespace with name '#{namespace}' already exists", caller[0..5] if has_txt_record        

        Libra.client_debug "Creating user entry rhlogin:#{rhlogin} ssh:#{ssh} namespace:#{namespace}" if Libra.c[:rpc_opts][:verbose]
        # TODO bit of a race condition here (can nsupdate fail on exists?)
            
        if Libra.c[:use_dynect_dns]
          Server.dyn_create_txt_record(namespace, auth_token)
          Server.dyn_publish(auth_token) # TODO should we publish on ensure?
        else
          Server.nsupdate_add_txt(namespace)
        end
        Libra.logger_debug "DEBUG: Attempting to add namespace '#{namespace}' for user '#{rhlogin}'"
        Libra.client_debug "Creating user entry rhlogin:#{rhlogin} ssh:#{ssh} namespace:#{namespace}" if Libra.c[:rpc_opts][:verbose]
        begin
          uuid = gen_small_uuid()
          user = new(rhlogin, ssh, namespace, uuid)
          user.update
          begin
            Nurture.libra_contact(rhlogin, uuid, namespace)
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
            if Libra.c[:use_dynect_dns]
              Server.dyn_login(auth_token)
              Server.dyn_delete_txt_record(namespace, auth_token)
              Server.dyn_publish(auth_token) # TODO should we publish on ensure?
            else
              Server.nsupdate_delete_txt(namespace)
            end
          ensure
            raise
          end
        end
      ensure
        if Libra.c[:use_dynect_dns] && auth_token
          Server.dyn_logout(auth_token)
        end
      end
    end
    
    #
    # Returns whether rhlogin with pw are registered
    #
    #   User.valid_registration?
    #
    def self.valid_registration?(rhlogin, password)
      if !Libra.c[:bypass_user_reg]
        raise UserException.new(107), "Invalid chars in RHlogin '#{rhlogin}' found", caller[0..5] if !Util.check_rhlogin(rhlogin)
        begin
          url = URI.parse(Libra.c[:streamline_url] + '/wapps/streamline/login.html')
          req = Net::HTTP::Post.new(url.path)
          
          req.set_form_data({ 'login' => rhlogin, 'password' => password, 'redirectUrl' => '/wapps/streamline/cloudVerify.html' })
          http = Net::HTTP.new(url.host, url.port)
          if url.scheme == "https"
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          response = http.start {|http| http.request(req)}
          
          #TODO IT is looking at returning the same thing as cloudVerify when no redirectUrl is passed
          cookie = response.response['set-cookie']
          while response.kind_of?(Net::HTTPRedirection)
            response = follow_redirect(response, cookie)
          end
          
          case response
          when Net::HTTPSuccess
            json = JSON.parse(response.body)
            roles = json['roles']
            if roles.index('cloud_access_1')
              return true
            elsif roles.index('cloud_access_request_1')
              raise UserValidationException.new(146), "Found valid credentials but you haven't been granted access to Express yet", caller[0..5]
            else
              raise UserValidationException.new(147), "Found valid credentials but you haven't requested access to Express yet", caller[0..5]
            end
          else
            Libra.client_debug "Response code from authentication: #{response.code}"
            #Libra.client_debug "HTTP response from server is #{response.body}"
          end
        rescue UserValidationException => e
          raise
        rescue Exception => e          
          Libra.logger_debug "Error message from authentication exception: #{e.message}"
          Libra.logger_debug e.backtrace
          raise UserValidationException.new(144), "Error communicating with user validation system.  If the problem persists please contact Red Hat support.", caller[0..5]
        end
        false
      elsif rhlogin == 'invalid_cred_user' #TODO remove fake user check before release
        false
      else
        true
      end
    end
    
    def self.follow_redirect(response, cookie)           
      headers = { "Cookie" => cookie }     
      url = URI.parse(response.header['location'])
      host = URI.parse(Libra.c[:streamline_url]).host
      port = url.port if url.port
      http = Net::HTTP.new(host, port)
      if url.scheme == "https"
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      response = http.get(url.path, headers)
      return response
    end
    
    #
    # Validates number of apps for a user is below the limit
    #
    def validate_app_limit
      num_apps = apps.length
      Libra.client_debug "Validating application limit #{@rhlogin}: num of apps(#{num_apps.to_s}) must be < app limit (#{Libra.c[:per_user_app_limit]})" if Libra.c[:rpc_opts][:verbose]
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
      Helper.s3.incrementally_list_bucket(Libra.c[:s3_bucket], { 'prefix' => 'user_info'}) do |result|         
        result[:contents].each do |bucket|
          if bucket[:key] =~ /\/user.json$/
            rhlogins << File.basename(File.dirname(bucket[:key]))
          end
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
      begin
        return User.from_json(Helper.s3.get(Libra.c[:s3_bucket], "user_info/#{rhlogin}/user.json")[:object])
      rescue Aws::AwsError => e
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
      json = JSON.generate({:rhlogin => rhlogin, :namespace => namespace, :ssh => ssh, :uuid => uuid})
      Libra.logger_debug "Updating user json:#{json}" if Libra.c[:rpc_opts][:verbose]
      Helper.s3.put(Libra.c[:s3_bucket], "user_info/#{rhlogin}/user.json", json)
    end
    
    #
    # Deletes the user with the current information
    #    
    def delete
      Libra.client_debug "DEBUG: Deleting user: #{rhlogin}" if Libra.c[:rpc_opts][:verbose]
      Helper.s3.delete(Libra.c[:s3_bucket], "user_info/#{rhlogin}/user.json")
    end

    #
    # Returns the servers that this user exists on
    #
    def servers
      # Use the cached value if it exists
      unless @servers
        @servers = {}

        # Make the rpc call to check
        Helper.rpc_get_fact("customer_#{rhlogin}") do |server, value|
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
                  { 'prefix' => "user_info/#{@rhlogin}/apps/"})
        app_list.each do |key|
          json = Helper.s3.get(Libra.c[:s3_bucket], key[:key])
          app_name = key[:key].sub("user_info/#{@rhlogin}/apps/", "").sub(".json", "")
          @apps[app_name.to_sym] = app_info(app_name)
        end
      end
      @apps
    end

    #
    # Create's an S3 cache of the app for easy tracking and verification
    #
    def create_app(app_name, framework, server,
                    creation_time=DateTime::now().strftime)
      json = JSON.generate({:framework => framework,
                            :server_identity => server.name,
                            :creation_time => creation_time})
      Helper.s3.put(Libra.c[:s3_bucket],
                    "user_info/#{@rhlogin}/apps/#{app_name}.json", json)
      JSON.parse(json)
    end
    
    #
    # Updates the S3 cache of the app
    #
    def update_app_server_identity(app_name, server)
      app_info = app_info(app_name)
      app_info['server_identity'] = server.name
      json = JSON.generate(app_info)
      Helper.s3.put(Libra.c[:s3_bucket],
                    "user_info/#{@rhlogin}/apps/#{app_name}.json", json)
    end

    #
    # Delete an S3 cache of an app
    #
    def delete_app(app_name)
      Helper.s3.delete(Libra.c[:s3_bucket],
                        "user_info/#{@rhlogin}/apps/#{app_name}.json")
    end

    #
    # Check if an application already exists
    #
    def app_info(app_name)
      return JSON.parse(Helper.s3.get(Libra.c[:s3_bucket],
            "user_info/#{@rhlogin}/apps/#{app_name}.json")[:object])
    rescue Aws::AwsError => e
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
