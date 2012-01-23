require 'rubygems'
require 'mongo'

module Cloud::Sdk
  class MongoDataStore < DataStore
    @cdk_ds_provider = Cloud::Sdk::MongoDataStore
    DOT = "."
    DOT_SUBSTITUTE = "(ö)"  
 
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
	      MongoDataStore.get_apps(user_id)
      end
    end
    
    def save(obj_type, user_id, id, obj_json)
      Rails.logger.debug "MongoDataStore.save(#{obj_type}, #{user_id}, #{id}, #{obj_json})\n\n"
      case obj_type
      when "CloudUser"
	      MongoDataStore.put_user(user_id, obj_json)
      when "Application"
	      MongoDataStore.put_app(user_id, id, obj_json)
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
      con = Mongo::Connection.new(Rails.application.config.cdk[:datastore_mongo][:host], 
                                  Rails.application.config.cdk[:datastore_mongo][:port])
      admin_db = con.db("admin")
      admin_db.authenticate(Rails.application.config.cdk[:datastore_mongo][:user],
                            Rails.application.config.cdk[:datastore_mongo][:password])
      con.db(Rails.application.config.cdk[:datastore_mongo][:db])
    end

    def self.collection
      MongoDataStore.db.collection(Rails.application.config.cdk[:datastore_mongo][:collection])
    end

    def self.get_user(user_id)
      bson = MongoDataStore.collection.find_one( "_id" => user_id )
      return nil if bson.to_s.strip.length == 0

      pkey = bson["_id"]
      bson.delete("_id")
      bson.delete("apps")
      { pkey => bson.to_json }
    end

    def self.get_users
      mcursor = MongoDataStore.collection.find()
      ret = []
      mcursor.each do |bson|
        bson.delete("_id")
        ret.push(bson.to_json)
      end
      ret
    end

    def self.get_app(user_id, id)
      select_fields = "apps.#{id}"
      bson = MongoDataStore.collection.find_one({ "_id" => user_id, "apps.#{id}" => { "$exists" => true } }, :fields => [select_fields])
      return nil if bson.to_s.strip.length == 0
      return nil if bson["apps"].to_s.strip.length == 0

      app_bson = bson["apps"][id]
      unescape(app_bson)

      { id => app_bson.to_json }
    end
  
    def self.get_apps(user_id)
      bson = MongoDataStore.collection.find_one({ "_id" => user_id }, :fields => ["apps"] )
      return [] if bson.to_s.strip.length == 0
      return [] if bson["apps"].to_s.strip.length == 0

      apps_bson = bson["apps"]
      ret = []
      apps_bson.each do |app_id, app_bson|
        
        unescape(app_bson)
        ret.push({ app_id => app_bson.to_json })
      end
      ret
    end

    def self.put_user(user_id, user_json)
      bson = MongoDataStore.collection.find_one( "_id" => user_id )
      if bson
        apps = bson["apps"]
        user_json["_id"] = user_id
        user_json["apps"] = apps
      else
        user_json["_id"] = user_id
      end
      MongoDataStore.collection.update({ "_id" => user_id }, user_json, { :upsert => true })
    end

    def self.put_app(user_id, id, app_json)
      field = "apps." + id
      escape(app_json)
      MongoDataStore.collection.update({ "_id" => user_id }, { "$set" => { field => app_json }})
    end

    def self.delete_user(user_id)
      MongoDataStore.collection.remove({ "_id" => user_id })
    end

    def self.delete_app(user_id, id)
      field = "apps." + id
      MongoDataStore.collection.update({ "_id" => user_id }, { "$unset" => { field => 1 }})
    end
    
    def self.escape(app_json)
      # Hack to overcome mongo limitation: Mongo key name can't have '.' char
      substitute_chars(app_json, DOT, DOT_SUBSTITUTE)
    end
    
    def self.unescape(app_bson)
      # Hack to overcome mongo limitation: Mongo key name can't have '.' char
      substitute_chars(app_bson, DOT_SUBSTITUTE, DOT)
    end

    def self.substitute_chars(app, from_char, to_char)
      embedded_carts = {}
      app["embedded"].each do |cart_name, cart_info|
        cart_name = cart_name.gsub(from_char, to_char)
        embedded_carts[cart_name] = cart_info
      end if app and app["embedded"]
      app["embedded"] = embedded_carts if app
    end

  end
end
