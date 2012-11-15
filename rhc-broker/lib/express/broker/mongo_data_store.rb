require 'pp'

module Express
  module Broker
    class MongoDataStore < OpenShift::MongoDataStore

      def obtain_distributed_lock(type, owner_id, allow_owner_multiple_access=false)
        Rails.logger.debug "MongoDataStore.obtain_distributed_lock(#{type},#{owner_id})\n\n"
        hash = nil
        query = nil
        if allow_owner_multiple_access
          query = {"type" => type, "$or" => [{"owner_id" => owner_id}, {"owner_id" => {"$type" => 10}}, {"owner_id" => {"$exists" => false}}]}
        else
          query = {"type" => type, "$or" => [{"owner_id" => {"$type" => 10}}, {"owner_id" => {"$exists" => false}}]}
        end
        begin
          hash = find_and_modify( distributed_lock_collection, {
            :query => query,
            :update => { "owner_id" => owner_id, "type" => type},
            :upsert => true,
            :new => true } )
        rescue Mongo::OperationFailure => e
        end
        return !hash.nil? && hash["owner_id"] == owner_id
      end
      
      def release_distributed_lock(type, owner_id=nil)
        Rails.logger.debug "MongoDataStore.release_distributed_lock(#{type},#{owner_id})\n\n"
        remove_filter = { "type" => type }
        if owner_id
          remove_filter["owner_id"] = owner_id
        end
        remove( distributed_lock_collection, remove_filter)
      end

      private

      def distributed_lock_collection
        MongoDataStore.instance.db.collection(Rails.application.config.datastore[:collections][:distributed_lock])
      end      

    end
  end
end
