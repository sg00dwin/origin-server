require 'libra/helper'
require 'libra/server'
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
    # if the user already exists.
    #
    def self.create(rhlogin, ssh, namespace)
      throw :user_exists if find(rhlogin)
      throw :namespace_already_exists if Server.get_dns_txt(namespace).length > 0
      # TODO bit of a race condition here (can nsupdate fail on exists?)
      Server.nsupdate_add_txt(namespace)
      puts "DEBUG: user.rb:create rhlogin:#{rhlogin} ssh:#{ssh} namespace:#{namespace}" if Libra.c[:rpc_opts][:verbose]
      uuid = gen_small_uuid()
      user = new(rhlogin, ssh, namespace, uuid)
      user.update
      user
    end
    
    #
    # Finds all registered rhlogins
    #
    #   User.find_all_rhlogins
    #
    def self.valid_registration?(rhlogin, password)
#=begin      
      begin
        url = URI.parse('https://streamline.devlab.phx1.redhat.com/wapps/streamline/login.html')
        #url = URI.parse('https://streamline1.stg.rhcloud.com/wapps/streamline/login.html')
        req = Net::HTTP::Post.new(url.path)
        
        req.set_form_data({ 'login' => rhlogin, 'password' => password })
        http = Net::HTTP.new(url.host, url.port)
        if url.scheme == "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        response = http.start {|http| http.request(req)}
        case response
        when Net::HTTPSuccess, Net::HTTPRedirection
          return true
        else
          puts "Problem with server. Response code was #{response.code}"
          #puts "HTTP response from server is #{response.body}"      
        end
      rescue Net::HTTPBadResponse => e
        puts e
        #raise
      end
      false
#=end
#true
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
          rhlogins << File.basename(bucket[:key], ".json")
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
      puts "DEBUG: user.rb:update json:#{json}" if Libra.c[:rpc_opts][:verbose]
      Helper.s3.put(Libra.c[:s3_bucket], "user_info/#{rhlogin}/user.json", json)
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
    def create_app(app_name, framework,
                    creation_time=DateTime::now().strftime)
      json = JSON.generate({:framework => framework,
                            :creation_time => creation_time})
      Helper.s3.put(Libra.c[:s3_bucket],
                    "user_info/#{@rhlogin}/apps/#{app_name}.json", json)
      JSON.parse(json)
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
