require 'pp'

module Express
  module Broker
    class MongoDataStore < Cloud::Sdk::MongoDataStore

      def find_district(uuid)
        Rails.logger.debug "MongoDataStore.find_district(#{uuid})\n\n"
        hash = MongoDataStore.district_collection.find_one( "_id" => uuid )
        hash_to_district_ret(hash)
      end
      
      def find_district_by_name(name)
        Rails.logger.debug "MongoDataStore.find_district_by_name(#{name})\n\n"
        hash = MongoDataStore.district_collection.find_one( "name" => name )
        hash_to_district_ret(hash)
      end
      
      def find_all_districts()
        Rails.logger.debug "MongoDataStore.find_all_districts()\n\n"
        mcursor = MongoDataStore.district_collection.find()
        cursor_to_district_hash(mcursor)
      end
      
      def find_district_with_node(server_identity)
        Rails.logger.debug "MongoDataStore.find_district_with_node(#{server_identity})\n\n"
        hash = MongoDataStore.district_collection.find_one({"server_identities.#{server_identity}" => { "$exists" => true } })
        hash_to_district_ret(hash)
      end
      
      def save_district(uuid, district_attrs)
        Rails.logger.debug "MongoDataStore.save_district(#{uuid}, #{district_attrs.pretty_inspect})\n\n"
        district_attrs["_id"] = uuid
        MongoDataStore.district_collection.update({ "_id" => uuid }, district_attrs, { :upsert => true })
        district_attrs.delete("_id")
      end
      
      def delete_district(uuid)
        Rails.logger.debug "MongoDataStore.delete_district(#{uuid})\n\n"
        MongoDataStore.district_collection.remove({ "_id" => uuid, "active_server_identities_size" => 0 })
      end
      
      def reserve_district_uid(uuid)
        Rails.logger.debug "MongoDataStore.reserve_district_uid(#{uuid})\n\n"
        hash = MongoDataStore.district_collection.find_and_modify({
          :query => {"_id" => uuid, "available_capacity" => {"$gt" => 0}},
          :update => {"$pop" => { "available_uids" => -1}, "$inc" => { "available_capacity" => -1 }},
          :new => false })
        hash["available_uids"][0]
      end
      
      def unreserve_district_uid(uuid, uid)
        Rails.logger.debug "MongoDataStore.reserve_district_uid(#{uuid})\n\n"
        MongoDataStore.district_collection.update({"_id" => uuid, "available_uids" => {"$ne" => uid}}, {"$push" => { "available_uids" => uid}, "$inc" => { "available_capacity" => 1 }})
      end
      
      def add_district_node(uuid, server_identity)
        Rails.logger.debug "MongoDataStore.add_district_node(#{uuid},#{server_identity})\n\n"
        MongoDataStore.district_collection.update({"_id" => uuid}, {"$set" => { "server_identities.#{server_identity}" => {"active" => true}}, "$inc" => { "active_server_identities_size" => 1 }})
      end
      
      def remove_district_node(uuid, server_identity)
        Rails.logger.debug "MongoDataStore.remove_district_node(#{uuid},#{server_identity})\n\n"
        hash = MongoDataStore.district_collection.find_and_modify({
          :query => {"_id" => uuid, "server_identities.#{server_identity}.active" => false}, 
          :update => {"$unset" => { "server_identities.#{server_identity}" => 1}} })
        return hash != nil
      end
      
      def deactivate_district_node(uuid, server_identity)
        Rails.logger.debug "MongoDataStore.deactivate_district_node(#{uuid},#{server_identity})\n\n"
        MongoDataStore.district_collection.update({"_id" => uuid}, {"$set" => { "server_identities.#{server_identity}" => {"active" => false}}, "$inc" => { "active_server_identities_size" => -1 }})
      end
      
      def add_district_uids(uuid, uids)
        Rails.logger.debug "MongoDataStore.add_district_capacity(#{uuid},#{uids})\n\n"
        MongoDataStore.district_collection.update({"_id" => uuid}, {"$pushAll" => { "available_uids" => uids }, "$inc" => { "available_capacity" => uids.length, "max_uid" => uids.length, "max_capacity" => uids.length }})
      end

      def remove_district_uids(uuid, uids)
        Rails.logger.debug "MongoDataStore.remove_district_capacity(#{uuid},#{uids})\n\n"
        MongoDataStore.district_collection.update({"_id" => uuid, "available_uids" => uids[0]}, {"$pullAll" => { "available_uids" => uids }, "$inc" => { "available_capacity" => -uids.length, "max_uid" => -uids.length, "max_capacity" => -uids.length }})
      end

      def inc_district_externally_reserved_uids_size(uuid)
        Rails.logger.debug "MongoDataStore.inc_district_externally_reserved_uids_size(#{uuid})\n\n"
        MongoDataStore.district_collection.update({"_id" => uuid}, {"$inc" => { "externally_reserved_uids_size" => 1 }})
      end
      
      def find_available_district(node_profile=nil)
        node_profile = node_profile ? node_profile : "std"
        hash = MongoDataStore.district_collection.find(
          { "available_capacity" => { "$gt" => 0 }, 
            "active_server_identities_size" => { "$gt" => 0 },
            "node_profile" => node_profile}).sort(["available_capacity", "descending"]).limit(1).next
        hash_to_district_ret(hash)
      end

      private
      
      def self.district_collection
        MongoDataStore.db.collection(Rails.configuration.datastore_mongo[:collections][:district])
      end
      
      def cursor_to_district_hash(cursor)
        return [] unless cursor
  
        districts = []
          cursor.each do |hash|
          districts.push(hash_to_district_ret(hash))
        end
        districts
      end

      def hash_to_district_ret(hash)
        return nil unless hash
        hash.delete("_id")
        hash
      end

    end
  end
end
