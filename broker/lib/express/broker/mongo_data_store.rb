require 'aws'

module Express
  module Broker
    class MongoDataStore < Cloud::Sdk::MongoDataStore
      
      def find_district(uuid)
        Rails.logger.debug "MongoDataStore.find_district(#{uuid})\n\n"
        MongoDataStore.get_district(uuid)
      end
      
      def find_all_districts()
        Rails.logger.debug "MongoDataStore.find_all_districts()\n\n"
        districts = MongoDataStore.get_districts()
        districts
      end
      
      def save_district(uuid, district_json)
        Rails.logger.debug "MongoDataStore.save_district(#{uuid}, #{district_json})\n\n"
        MongoDataStore.put_district(uuid, district_json)
      end
      
      def delete_district(uuid)
        Rails.logger.debug "MongoDataStore.delete_district(#{uuid})\n\n"
        MongoDataStore.delete_district(uuid)
      end

      private
      
      def self.district_collection
        MongoDataStore.db.collection(Rails.application.config.datastore_mongo[:collection])
      end

      #
      # Returns all the district S3 JSON objects
      #
      def self.get_districts      
        mcursor = MongoDataStore.district_collection.find()
        return [] unless mcursor
  
        districts = []
        mcursor.each do |bson|
          pkey = bson["_id"]
          bson.delete("_id")
          bson.delete("apps")
          districts.push(bson.to_json)
        end
        districts
      end

      def self.put_district(uuid, district_json)        
        mcursor = MongoDataStore.district_collection.find( "_id" => uuid )
        bson = mcursor.next
        if bson
          district_json["_id"] = uuid
          MongoDataStore.district_collection.update({ "_id" => uuid }, district_json)
        else
          district_json["_id"] = uuid
          MongoDataStore.district_collection.insert(district_json)
        end
      end

      #
      # Returns the district json object
      #
      def self.get_district(uuid)
        mcursor = MongoDataStore.district_collection.find( "_id" => uuid )
        bson = mcursor.next
        return nil unless bson
  
        bson.delete("_id")
        bson.to_json
      end

      def self.delete_district(uuid)
        MongoDataStore.district_collection.remove({ "_id" => uuid })
      end

    end
  end
end
