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
          DataStore.get_app_s3(user_id, id)
        end
      end
      
      def find_all(obj_type, user_id=nil)
        Rails.logger.debug "DataStore.find_all(#{obj_type}, #{user_id})\n\n"
        case obj_type
        when "CloudUser"
          DataStore.get_users_s3
        when "Application"
          DataStore.get_apps_s3(user_id)
        end
      end
      
      def save(obj_type, user_id, id, serialized_obj)
        Rails.logger.debug "DataStore.save(#{obj_type}, #{user_id}, #{id}, #{serialized_obj})\n\n"
        case obj_type
        when "CloudUser"
          DataStore.put_user_s3(user_id, serialized_obj)
        when "Application"
          DataStore.put_app_s3(user_id, id, serialized_obj)
        end
      end
      
      def delete(obj_type, user_id, id)
        Rails.logger.debug "DataStore.delete(#{obj_type}, #{user_id}, #{id})\n\n"
        case obj_type
        when "CloudUser"
          DataStore.delete_user_s3(user_id)
        when "Application"
          DataStore.delete_app_s3(user_id, id)
        end
      end
      
      def find_district(uuid)
        Rails.logger.debug "DataStore.find_district(#{uuid})\n\n"
        DataStore.get_district_s3(uuid)
      end
      
      def find_all_districts()
        Rails.logger.debug "DataStore.find_all_districts()\n\n"
        districts = DataStore.get_districts_s3()
        districts
      end
      
      def save_district(uuid, serialized_district)
        Rails.logger.debug "DataStore.save_district(#{uuid}, #{serialized_district})\n\n"
        DataStore.put_district_s3(uuid, serialized_district)
      end
      
      def delete_district(uuid)
        Rails.logger.debug "DataStore.delete_district(#{uuid})\n\n"
        DataStore.delete_district_s3(uuid)
      end

      private
      
      def self.s3
        # Setup the global access configuration
        AWS.config(
          :access_key_id => Rails.application.config.datastore[:aws_key],
          :secret_access_key => Rails.application.config.datastore[:aws_secret],
          :ssl_ca_file => "/etc/pki/tls/certs/ca-bundle.trust.crt"
        )
    
        # Return the AMZ connection
        AWS::S3.new
      end
    
      def self.bucket
        s3.buckets[Rails.application.config.datastore[:s3_bucket]]
      end
      
      #
      # Returns all the user S3 JSON objects
      #
      def self.get_users_s3
        users = {}
        bucket.objects.with_prefix('user_info').each do |user_obj|
          if user_obj.key.end_with?("/user.json") && !user_obj.key.end_with?("/apps/user.json")
            users[File.basename(File.dirname(user_obj.key))] = user_obj.read
          end
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
      
      def self.delete_user_s3(rhlogin)
        obj = bucket.objects["user_info/#{rhlogin}/user.json"]
        obj.delete if obj.exists?
      end

      #
      # Returns all the district S3 JSON objects
      #
      def self.get_districts_s3
        districts = []
        bucket.objects.with_prefix('districts').each do |district_obj|
          if district_obj.key =~ /\/.+\.json$/
            districts << district_obj.read
          end
        end
        districts
      end

      def self.put_district_s3(uuid, json)
        begin
          obj = bucket.objects["districts/#{uuid}.json"]
          obj.write(json)
        rescue AWS::S3::Errors::NoSuchKey
          return nil
        end
      end

      #
      # Returns the S3 district json object
      #
      def self.get_district_s3(uuid)
        begin
          bucket.objects["districts/#{uuid}.json"].read
        rescue AWS::S3::Errors::NoSuchKey
          return nil
        end
      end

      def self.delete_district_s3(uuid)
        obj = bucket.objects["districts/#{uuid}.json"]
        obj.delete if obj.exists?
      end

      def self.get_apps_s3(rhlogin)
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
      
      def self.put_app_s3(rhlogin, app_name, serialized_obj)
        bucket.objects["user_info/#{rhlogin}/apps/#{app_name}.json"].write(serialized_obj)
      end

      def self.delete_app_s3(rhlogin, app_name)
        obj = bucket.objects["user_info/#{rhlogin}/apps/#{app_name}.json"]
        obj.delete if obj.exists?
      end
    end
  end
end
