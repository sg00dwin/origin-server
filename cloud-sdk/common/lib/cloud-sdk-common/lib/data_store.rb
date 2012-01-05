module Cloud
  module Sdk
    class DataStore
      @cdk_ds_provider = Cloud::Sdk::DataStore
      
      def self.provider=(provider_class)
        @cdk_ds_provider = provider_class
      end
      
      def self.instance
        @cdk_ds_provider.new
      end
      
      def find(obj_type, user_id, id)
        Rails.logger.debug "DataStore.find(#{obj_type}, #{user_id}, #{id})\n\n"
      end
      
      def find_all(obj_type, user_id=nil)
        Rails.logger.debug "DataStore.find_all(#{obj_type}, #{user_id})\n\n"
      end
      
      def save(obj_type, user_id, id, serialized_obj)
        Rails.logger.debug "DataStore.save(#{obj_type}, #{user_id}, #{id}, #{serialized_obj})\n\n"
      end
      
      def delete(obj_type, user_id, id)
        Rails.logger.debug "DataStore.delete(#{obj_type}, #{user_id}, #{id})\n\n"
      end
    end
  end
end