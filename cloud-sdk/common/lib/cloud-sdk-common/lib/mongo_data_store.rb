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
    
    def create(obj_type, user_id, id, obj_json)
      Rails.logger.debug "MongoDataStore.create(#{obj_type}, #{user_id}, #{id}, #{obj_json})\n\n"
      case obj_type
      when "CloudUser"
        MongoDataStore.add_user(user_id, obj_json)
      when "Application"
        MongoDataStore.add_app(user_id, id, obj_json)
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
      con = Mongo::Connection.new(Rails.configuration.cdk[:datastore_mongo][:host], 
                                  Rails.configuration.cdk[:datastore_mongo][:port])
      admin_db = con.db("admin")
      admin_db.authenticate(Rails.configuration.cdk[:datastore_mongo][:user],
                            Rails.configuration.cdk[:datastore_mongo][:password])
      con.db(Rails.configuration.cdk[:datastore_mongo][:db])
    end

    def self.collection
      MongoDataStore.db.collection(Rails.configuration.cdk[:datastore_mongo][:collections][:user])
    end

    def self.get_user(user_id)
      bson = MongoDataStore.collection.find_one( "_id" => user_id )
      return nil if bson.to_s.strip.length == 0

      user_bson_to_ret(bson)
    end

    def self.get_users
      mcursor = MongoDataStore.collection.find()
      ret = []
      mcursor.each do |bson|
        ret.push(user_bson_to_ret(bson))
      end
      ret
    end
    
    def self.user_bson_to_ret(bson)
      pkey = bson["_id"]
      bson.delete("_id")
      bson.delete("apps")
      { pkey => bson.to_json }
    end

    def self.get_app(user_id, id)
      field = "apps.#{id}"
      bson = MongoDataStore.collection.find_one({ "_id" => user_id, field => { "$exists" => true } }, :fields => [field])
      return nil if bson.to_s.strip.length == 0
      return nil if bson["apps"].to_s.strip.length == 0

      app_bson = bson["apps"][id]
      app_bson_to_ret(id, app_bson)
    end
  
    def self.get_apps(user_id)
      bson = MongoDataStore.collection.find_one({ "_id" => user_id }, :fields => ["apps"] )
      return [] if bson.to_s.strip.length == 0
      return [] if bson["apps"].to_s.strip.length == 0

      apps_bson = bson["apps"]
      ret = []
      apps_bson.each do |app_id, app_bson|
        ret.push(app_bson_to_ret(app_id, app_bson))
      end
      ret
    end
    
    def self.app_bson_to_ret(id, bson)
      unescape(bson)
      { id => bson.to_json }
    end

    def self.put_user(user_id, user_json)
      MongoDataStore.collection.update({ "_id" => user_id }, { "$set" => user_json }, { :upsert => true })
    end
    
    def self.add_user(user_id, user_json)
      user_json["_id"] = user_id
      MongoDataStore.collection.insert(user_json)
    end

    def self.put_app(user_id, id, app_json)
      field = "apps.#{id}"
      escape(app_json)
      MongoDataStore.collection.update({ "_id" => user_id }, { "$set" => { field => app_json }})
    end

    def self.add_app(user_id, id, app_json)
      field = "apps.#{id}"
      escape(app_json)
      bson = MongoDataStore.collection.find_and_modify({
        :query => { "_id" => user_id, field => { "$exists" => false }, "$where" => "this.consumed_gears < this.max_gears"},
        :update => { "$set" => { field => app_json }, "$inc" => { "consumed_gears" => 1 }} })
      raise Cloud::Sdk::UserException.new("#{user_id} has already reached the application limit", 104) if bson == nil
    end

    def self.delete_user(user_id)
      MongoDataStore.collection.remove({ "_id" => user_id })
    end

    def self.delete_app(user_id, id)
      field = "apps.#{id}"
      MongoDataStore.collection.update({ "_id" => user_id, field => { "$exists" => true }}, 
                                       { "$unset" => { field => 1 }, "$inc" => { "consumed_gears" => -1 }})
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
