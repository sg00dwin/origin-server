require 'rubygems'
require 'mongo'

module Cloud::Sdk
  class MongoDataStore < DataStore
    @cdk_ds_provider = Cloud::Sdk::MongoDataStore
   
    def self.provider=(provider_class)
      @cdk_ds_provider = provider_class
    end
    
    def self.instance
      @cdk_ds_provider.new
    end
    
    def find(obj_type, user_id, id)
      Rails.logger.debug "MongoDataStore.find(#{obj_type}, #{user_id}, #{id})\n\n"
      case obj_type
      when "CloudUser"
	MongoDataStore.get_user(user_id)
      when "Application"
	MongoDataStore.get_app(user_id, id)
      end
    end
    
    def find_all(obj_type, user_id=nil)
      Rails.logger.debug "MongoDataStore.find_all(#{obj_type}, #{user_id})\n\n"
      case obj_type
      when "CloudUser"
	MongoDataStore.get_users
      when "Application"
	MongoDataStore.get_user_apps(user_id)
      end
    end
    
    def save(obj_type, user_id, id, serialized_obj)
      Rails.logger.debug "MongoDataStore.save(#{obj_type}, #{user_id}, #{id}, #{serialized_obj})\n\n"
      case obj_type
      when "CloudUser"
	MongoDataStore.put_user(user_id, serialized_obj)
      when "Application"
	MongoDataStore.put_app(user_id, id, serialized_obj)
      end
    end
    
    def delete(obj_type, user_id, id=nil)
      Rails.logger.debug "MongoDataStore.delete(#{obj_type}, #{user_id}, #{id})\n\n"
      case obj_type
      when "CloudUser"
	MongoDataStore.delete_user(user_id)
      when "Application"
	MongoDataStore.delete_app(user_id, id)
      end
    end

    private

    def self.db
      con = Mongo::Connection.new(Rails.application.config.cdk.datastore.mongo[:host], 
                                  Rails.application.config.cdk.datastore.mongo[:port])
      con.db(Rails.application.config.cdk.datastore.mongo[:db])
    end

    def self.collection
      MongoDataStore.db.collection(Rails.application.config.cdk.datastore.mongo[:collection])
    end

    def self.get_user(user_id)
      MongoDataStore.collection.find( "_id" => user_id )
    end

    def self.get_users
      MongoDataStore.collection.find()
    end

    def self.get_app(user_id, id)
      select_fields = "apps." + id
      MongoDataStore.collection.find({ "_id" => user_id }, :fields => [select_fields]) 
    end
  
    def self.get_user_apps(user_id)
      MongoDataStore.collection.find({ "_id" => user_id }, :fields => ["apps"] )
    end

    def self.put_user(user_id, serialized_obj)
      MongoDataStore.collection.update({ "_id" => user_id }, serialized_obj)
    end

    def self.put_app(user_id, id, serialized_obj)
      field = "apps." + id
      MongoDataStore.collection.update({ "_id" => user_id }, { "$set" => { field => serialized_obj }})
    end

    def self.delete_user(user_id)
      MongoDataStore.collection.remove({ "_id" => user_id })
    end

    def self.delete_app(user_id, id)
      field = "apps." + id
      MongoDataStore.collection.update({ "_id" => user_id }, { "$unset" => field })
    end

  end
end
