require 'aws'

module Express
  module Broker
    class MongoDataStore < Cloud::Sdk::MongoDataStore

      def find_district(uuid)
        Rails.logger.debug "MongoDataStore.find_district(#{uuid})\n\n"
        bson = MongoDataStore.district_collection.find_one( "_id" => uuid )
        bson_to_district_json(bson)
      end
      
      def find_all_districts()
        Rails.logger.debug "MongoDataStore.find_all_districts()\n\n"
        mcursor = MongoDataStore.district_collection.find()
        cursor_to_district_json(mcursor)
      end
      
      def find_district_with_node(server_identity)
        Rails.logger.debug "MongoDataStore.find_district_with_node(#{server_identity})\n\n"
        bson = MongoDataStore.district_collection.find_one({"server_identities.#{server_identity}" => { "$exists" => true } })
        bson_to_district_json(bson)
      end
      
      def save_district(uuid, district_json)
        Rails.logger.debug "MongoDataStore.save_district(#{uuid}, #{district_json})\n\n"
        district_json["_id"] = uuid
        MongoDataStore.district_collection.update({ "_id" => uuid }, district_json, { :upsert => true })
      end
      
      def delete_district(uuid)
        Rails.logger.debug "MongoDataStore.delete_district(#{uuid})\n\n"
        MongoDataStore.district_collection.remove({ "_id" => uuid })
      end
      
      def reserve_district_uid(uuid)
        Rails.logger.debug "MongoDataStore.reserve_district_uid(#{uuid})\n\n"
        bson = MongoDataStore.district_collection.find_and_modify({
          :query => {"_id" => uuid},
          :update => {"$pop" => { "available_uids" => -1}, "$inc" => { "available_capacity" => -1 }},
          :new => false })
        bson["available_uids"][0]
      end
      
      def unreserve_district_uid(uuid, uid)
        Rails.logger.debug "MongoDataStore.reserve_district_uid(#{uuid})\n\n"
        MongoDataStore.district_collection.update({"_id" => uuid}, {"$push" => { "available_uids" => uid}, "$inc" => { "available_capacity" => 1 }})
      end
      
      def add_district_node(uuid, server_identity)
        Rails.logger.debug "MongoDataStore.add_district_node(#{uuid},#{server_identity})\n\n"
        MongoDataStore.district_collection.update({"_id" => uuid}, {"$set" => { "server_identities.#{server_identity}" => {"active" => true}}, "$inc" => { "active_server_identities_size" => 1 }})
      end
      
      def remove_district_node(uuid, server_identity)
        Rails.logger.debug "MongoDataStore.remove_district_node(#{uuid},#{server_identity})\n\n"
        bson = MongoDataStore.district_collection.find_and_modify({
          :query => {"_id" => uuid, "server_identities.#{server_identity}.active" => false}, 
          :update => {"$unset" => { "server_identities.#{server_identity}" => 1}} })
        return bson != nil
      end
      
      def deactivate_district_node(uuid, server_identity)
        Rails.logger.debug "MongoDataStore.deactivate_district_node(#{uuid},#{server_identity})\n\n"
        MongoDataStore.district_collection.update({"_id" => uuid}, {"$set" => { "server_identities.#{server_identity}" => {"active" => false}}, "$inc" => { "active_server_identities_size" => -1 }})
      end
      
      def add_district_uids(uuid, uids)
        Rails.logger.debug "MongoDataStore.add_district_capacity(#{uuid},#{uids})\n\n"
        MongoDataStore.district_collection.update({"_id" => uuid}, {"$pushAll" => { "available_uids" => uids }, "$inc" => { "available_capacity" => uids.length, "max_uid" => uids.length }})
      end

      def remove_district_uids(uuid, uids)
        Rails.logger.debug "MongoDataStore.remove_district_capacity(#{uuid},#{uids})\n\n"
        MongoDataStore.district_collection.update({"_id" => uuid, "available_uids" => uids[0]}, {"$pullAll" => { "available_uids" => uids }, "$inc" => { "available_capacity" => -uids.length, "max_uid" => -uids.length }})
      end
      
      def find_available_district
        bson = MongoDataStore.district_collection.find(
          { "available_capacity" => { "$gt" => 0 }, 
            "active_server_identities_size" => { "$gt" => 0 } }).sort(["available_capacity", "descending"]).limit(1).next
        bson_to_district_json(bson)
      end

      private
      
      def self.district_collection
        MongoDataStore.db.collection(Rails.configuration.datastore_mongo[:collections][:district])
      end
      
      def cursor_to_district_json(cursor)
        return [] unless cursor
  
        districts = []
          cursor.each do |bson|
          bson.delete("_id")
          districts.push(bson.to_json)
        end
        districts
      end

      def bson_to_district_json(bson)
        return nil unless bson
  
        bson.delete("_id")
        bson.to_json
      end

    end
  end
end
