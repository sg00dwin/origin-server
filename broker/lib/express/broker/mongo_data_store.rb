require 'pp'

module Express
  module Broker
    class MongoDataStore < StickShift::MongoDataStore
      
      def find_district(uuid)
        Rails.logger.debug "MongoDataStore.find_district(#{uuid})\n\n"
        hash = find_one( district_collection, "_id" => uuid )
        hash_to_district_ret(hash)
      end
      
      def find_district_by_name(name)
        Rails.logger.debug "MongoDataStore.find_district_by_name(#{name})\n\n"
        hash = find_one( district_collection, "name" => name )
        hash_to_district_ret(hash)
      end
      
      def find_all_districts()
        Rails.logger.debug "MongoDataStore.find_all_districts()\n\n"
        MongoDataStore.rescue_con_failure do
          mcursor = district_collection.find()
          cursor_to_district_hash(mcursor)
        end
      end
      
      def find_district_with_node(server_identity)
        Rails.logger.debug "MongoDataStore.find_district_with_node(#{server_identity})\n\n"
        hash = find_one( district_collection, {"server_identities.name" => server_identity } )
        hash_to_district_ret(hash)
      end
      
      def save_district(uuid, district_attrs)
        Rails.logger.debug "MongoDataStore.save_district(#{uuid}, #{district_attrs.pretty_inspect})\n\n"
        district_attrs["_id"] = uuid
        orig_server_identities = district_attrs["server_identities"] 
        district_attrs_to_internal(district_attrs)
        update( district_collection, { "_id" => uuid }, district_attrs, { :upsert => true } )
        district_attrs.delete("_id")
        district_attrs["server_identities"] = orig_server_identities
      end
      
      def delete_district(uuid)
        Rails.logger.debug "MongoDataStore.delete_district(#{uuid})\n\n"
        remove( district_collection, { "_id" => uuid, "active_server_identities_size" => 0 } )
      end
      
      def reserve_district_uid(uuid)
        Rails.logger.debug "MongoDataStore.reserve_district_uid(#{uuid})\n\n"
        hash = find_and_modify( district_collection, {
          :query => {"_id" => uuid, "available_capacity" => {"$gt" => 0}},
          :update => {"$pop" => { "available_uids" => -1}, "$inc" => { "available_capacity" => -1 }},
          :new => false })
        hash["available_uids"][0]
      end

      def unreserve_district_uid(uuid, uid)
        Rails.logger.debug "MongoDataStore.unreserve_district_uid(#{uuid})\n\n"
        update( district_collection, {"_id" => uuid, "available_uids" => {"$ne" => uid}}, {"$push" => { "available_uids" => uid}, "$inc" => { "available_capacity" => 1 }} )
      end

      def add_district_node(uuid, server_identity)
        Rails.logger.debug "MongoDataStore.add_district_node(#{uuid},#{server_identity})\n\n"
        update( district_collection, {"_id" => uuid, "server_identities.name" => { "$ne" => server_identity }}, {"$push" => { "server_identities" => {"name" => server_identity, "active" => true}}, "$inc" => { "active_server_identities_size" => 1 }} )
      end

      def remove_district_node(uuid, server_identity)
        Rails.logger.debug "MongoDataStore.remove_district_node(#{uuid},#{server_identity})\n\n"
        hash = find_and_modify( district_collection, {
          :query => { "_id" => uuid, "server_identities" => {"$elemMatch" => {"name" => server_identity, "active" => false}}}, 
          :update => { "$pull" => { "server_identities" => {"name" => server_identity }}} } )
        return hash != nil
      end

      def deactivate_district_node(uuid, server_identity)
        Rails.logger.debug "MongoDataStore.deactivate_district_node(#{uuid},#{server_identity})\n\n"
        update( district_collection, {"_id" => uuid, "server_identities" => {"$elemMatch" => {"name" => server_identity, "active" => true}}}, {"$set" => { "server_identities.$.active" => false}, "$inc" => { "active_server_identities_size" => -1 }} )
      end
      
      def activate_district_node(uuid, server_identity)
        Rails.logger.debug "MongoDataStore.activate_district_node(#{uuid},#{server_identity})\n\n"
        update( district_collection, {"_id" => uuid, "server_identities" => {"$elemMatch" => {"name" => server_identity, "active" => false}}}, {"$set" => { "server_identities.$.active" => true}, "$inc" => { "active_server_identities_size" => 1 }} )
      end
      
      def add_district_uids(uuid, uids)
        Rails.logger.debug "MongoDataStore.add_district_capacity(#{uuid},#{uids})\n\n"
        update( district_collection, {"_id" => uuid}, {"$pushAll" => { "available_uids" => uids }, "$inc" => { "available_capacity" => uids.length, "max_uid" => uids.length, "max_capacity" => uids.length }} )
      end

      def remove_district_uids(uuid, uids)
        Rails.logger.debug "MongoDataStore.remove_district_capacity(#{uuid},#{uids})\n\n"
        update( district_collection, {"_id" => uuid, "available_uids" => uids[0]}, {"$pullAll" => { "available_uids" => uids }, "$inc" => { "available_capacity" => -uids.length, "max_uid" => -uids.length, "max_capacity" => -uids.length }} )
      end

      def inc_district_externally_reserved_uids_size(uuid)
        Rails.logger.debug "MongoDataStore.inc_district_externally_reserved_uids_size(#{uuid})\n\n"
        update( district_collection, {"_id" => uuid}, {"$inc" => { "externally_reserved_uids_size" => 1 }} )
      end
      
      def find_available_district(node_profile=nil)
        node_profile = node_profile ? node_profile : "small"
        MongoDataStore.rescue_con_failure do
          hash = district_collection.find(
            { "available_capacity" => { "$gt" => 0 }, 
              "active_server_identities_size" => { "$gt" => 0 },
              "node_profile" => node_profile}).sort(["available_capacity", "descending"]).limit(1).next
          hash_to_district_ret(hash)
        end
      end

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

      def district_collection
        MongoDataStore.instance.db.collection(Rails.application.config.datastore[:collections][:district])
      end

      def distributed_lock_collection
        MongoDataStore.instance.db.collection(Rails.application.config.datastore[:collections][:distributed_lock])
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
        if hash["server_identities"]
          server_identities = {}
          hash["server_identities"].each do |server_identity|
            name = server_identity["name"]
            server_identity.delete("name")
            server_identities[name] = server_identity
          end
          hash["server_identities"] = server_identities
        else
          hash["server_identities"] = {}
        end
        hash
      end
      
      def district_attrs_to_internal(district_attrs)
        if district_attrs
          if district_attrs["server_identities"]
            server_identities = []
            district_attrs["server_identities"].each do |name, server_identity|
              server_identity["name"] = name
              server_identities.push(server_identity)
            end
            district_attrs["server_identities"] = server_identities
          else
            district_attrs["server_identities"] = []
          end
        end
        district_attrs
      end

    end
  end
end
