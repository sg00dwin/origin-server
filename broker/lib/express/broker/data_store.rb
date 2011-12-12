require 'aws'

module Express
  module Broker
    class DataStore
      def find(obj_type, user_id, id)
        Rails.logger.debug "DataStore.find(#{obj_type}, #{user_id}, #{id})\n\n"
        case obj_type
        when "CloudUser"
          DataStore.get_user_s3(id)
        when "Application"
          DataStore.get_app_s3(user_id,id)
        end
      end
      
      def find_all(obj_type, user_id)
        Rails.logger.debug "DataStore.find_all(#{obj_type}, #{user_id})\n\n"
        case obj_type
        when "CloudUser"
          DataStore.get_user_s3(id)
        when "Application"
          DataStore.get_user_apps_s3(user_id)
        end
      end
      
      def save(obj_type, user_id, id, serialized_obj)
        Rails.logger.debug "DataStore.save(#{obj_type}, #{user_id}, #{id}, #{serialized_obj})\n\n"
        case obj_type
        when "CloudUser"
          DataStore.put_user_s3(user_id, serialized_obj)
        when "Application"
          DataStore.put_app_s3(user_id,id,serialized_obj)
        end
      end
      
      def delete(obj_type, user_id, id)
        Rails.logger.debug "DataStore.delete(#{obj_type}, #{user_id}, #{id})\n\n"
        case obj_type
        when "CloudUser"
          DataStore.delete_user(user_id)
        when "Application"
          DataStore.delete_app(user_id,id)
        end
      end
      
      private
      
      def self.s3
        # Setup the global access configuration
        AWS.config(
          :access_key_id => Rails.application.config.cdk[:aws_key],
          :secret_access_key => Rails.application.config.cdk[:aws_secret],
          :ssl_ca_file => "/etc/pki/tls/certs/ca-bundle.trust.crt"
        )
    
        # Return the AMZ connection
        AWS::S3.new
      end
    
      def self.bucket
        s3.buckets[Rails.application.config.cdk[:s3_bucket]]
      end
      
      #
      # Returns all the user S3 JSON objects
      #
      def self.get_users_s3
        users = {}
        bucket.objects.with_prefix('user_info').each do |user_obj|
          users[user_obj.key.gsub("user_info/")[0..-6]] = user_obj.read
        end
        users
      end
    
      def self.put_user_s3(rhlogin, json)
        begin
          obj = bucket.objects["user_info/#{rhlogin}/user.json"]
          obj.write(json)
        rescue AWS::S3::Errors::NoSuchKey
          return nil
        end
      end
    
      #
      # Returns the S3 user json object
      #
      def self.get_user_s3(rhlogin)
        begin
          {rhlogin => bucket.objects["user_info/#{rhlogin}/user.json"].read}
        rescue AWS::S3::Errors::NoSuchKey
          return nil
        end
      end
    
      def self.get_user_apps_s3(rhlogin)
        apps = {}
        app_prefix = "user_info/#{rhlogin}/apps/"
        bucket.objects.with_prefix(app_prefix).map do |app_obj|
          serialized_obj = app_obj.read
          apps[app_obj.key.gsub(app_prefix,'')[0..-6]] = serialized_obj unless serialized_obj.empty?
        end
        apps
      end
    
      #
      # Returns the application S3 json object
      #
      def self.get_app_s3(rhlogin, app_name)
        begin
          {app_name => bucket.objects["user_info/#{rhlogin}/apps/#{app_name}.json"].read}
        rescue AWS::S3::Errors::NoSuchKey
          return nil
        end
      end
      
      def self.put_app_s3(rhlogin,app_name,serialized_obj)
        bucket.objects["user_info/#{rhlogin}/apps/#{app_name}.json"].write(serialized_obj)
      end
    
      def self.delete_user(rhlogin)
        obj = bucket.objects["user_info/#{rhlogin}"]
        obj.delete if obj.exists?
      end

      def self.delete_app(rhlogin,app_name)
        obj = bucket.objects["user_info/#{rhlogin}/apps/#{app_name}.json"]
        obj.delete if obj.exists?
      end
    end
  end
end
