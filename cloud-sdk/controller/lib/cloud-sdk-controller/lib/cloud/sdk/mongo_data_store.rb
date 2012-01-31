require 'rubygems'
require 'mongo'
require 'pp'

module Cloud::Sdk
  class MongoDataStore < DataStore
    @cdk_ds_provider = Cloud::Sdk::MongoDataStore
    MAX_CON_RETRIES   = 60
    CON_RETRY_WAIT_TM = 0.5 # in secs
 
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
    
    def save(obj_type, user_id, id, obj_attrs)
      Rails.logger.debug "MongoDataStore.save(#{obj_type}, #{user_id}, #{id}, #{obj_attrs.pretty_inspect})\n\n"
      case obj_type
      when "CloudUser"
	      MongoDataStore.put_user(user_id, obj_attrs)
      when "Application"
	      MongoDataStore.put_app(user_id, id, obj_attrs)
      end
    end
    
    def create(obj_type, user_id, id, obj_attrs)
      Rails.logger.debug "MongoDataStore.create(#{obj_type}, #{user_id}, #{id}, #{obj_attrs.pretty_inspect})\n\n"
      case obj_type
      when "CloudUser"
        MongoDataStore.add_user(user_id, obj_attrs)
      when "Application"
        MongoDataStore.add_app(user_id, id, obj_attrs)
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

    # Ensure retry upon connection failure
    def self.rescue_con_failure(max_retries=MAX_CON_RETRIES, retry_wait_tm=CON_RETRY_WAIT_TM)
      retries = 0
      begin
        yield
      rescue Mongo::ConnectionFailure => ex
        retries += 1
        raise ex if retries > max_retries
        sleep(retry_wait_tm)
        retry
      end
    end

    def self.db
      if Rails.configuration.cdk[:datastore_mongo][:replica_set]
        con = Mongo::ReplSetConnection.new(*Rails.configuration.cdk[:datastore_mongo][:host_port] \
                                           << {:read => :secondary})
      else
        con = Mongo::Connection.new(Rails.configuration.cdk[:datastore_mongo][:host_port][0], 
                                    Rails.configuration.cdk[:datastore_mongo][:host_port][1])
      end
      admin_db = con.db("admin")
      admin_db.authenticate(Rails.configuration.cdk[:datastore_mongo][:user],
                            Rails.configuration.cdk[:datastore_mongo][:password])
      con.db(Rails.configuration.cdk[:datastore_mongo][:db])
    end

    def self.collection
      MongoDataStore.db.collection(Rails.configuration.cdk[:datastore_mongo][:collections][:user])
    end

    def self.find_one(*args)
      MongoDataStore.rescue_con_failure do
        MongoDataStore.collection.find_one(*args)
      end
    end

    def self.find_and_modify(*args)
      MongoDataStore.rescue_con_failure do
        MongoDataStore.collection.find_and_modify(*args)
      end
    end

    def self.insert(*args)
      MongoDataStore.rescue_con_failure do
        MongoDataStore.collection.insert(*args)
      end
    end

    def self.update(*args)
      MongoDataStore.rescue_con_failure do
        MongoDataStore.collection.update(*args)
      end
    end

    def self.remove(*args)
      MongoDataStore.rescue_con_failure do
        MongoDataStore.collection.remove(*args)
      end
    end

    def self.get_user(user_id)
      hash = MongoDataStore.find_one( "_id" => user_id )
      return nil unless hash && !hash.empty?

      user_hash_to_ret(hash)
    end

    def self.get_users
      MongoDataStore.rescue_con_failure do
        mcursor = MongoDataStore.collection.find()
        ret = []
        mcursor.each do |hash|
          ret.push(user_hash_to_ret(hash))
        end
        ret
      end
    end
    
    def self.user_hash_to_ret(hash)
      hash.delete("_id")
      if hash["apps"] 
        hash["apps"] = apps_hash_to_apps_ret(hash["apps"])
      end
      hash
    end

    def self.get_app(user_id, id)
      hash = MongoDataStore.find_one({ "_id" => user_id, "apps.name" => id }, :fields => ["apps"])
      return nil unless hash && !hash.empty?

      app_hash = nil
      hash["apps"].each do |app|
        if app["name"] == id
          app_hash = app
          break
        end
      end
      app_hash_to_ret(app_hash)
    end
  
    def self.get_apps(user_id)
      hash = MongoDataStore.find_one({ "_id" => user_id }, :fields => ["apps"] )
      return [] unless hash && !hash.empty?
      return [] unless hash["apps"] && !hash["apps"].empty?
      apps_hash_to_apps_ret(hash["apps"])
    end

    def self.put_user(user_id, changed_user_attrs)
      changed_user_attrs.delete("apps")
      MongoDataStore.update({ "_id" => user_id }, { "$set" => changed_user_attrs })
    end
    
    def self.add_user(user_id, user_attrs)
      user_attrs["_id"] = user_id
      user_attrs.delete("apps")
      MongoDataStore.insert(user_attrs)
      user_attrs.delete("_id")
    end

    def self.put_app(user_id, id, app_attrs)
      
      orig_embedded = app_attrs["embedded"] 
      app_attrs_to_internal(app_attrs)

      MongoDataStore.update({ "_id" => user_id, "apps.name" => id}, { "$set" => { "apps.$" => app_attrs }} )
      app_attrs["embedded"] = orig_embedded 
    end

    def self.add_app(user_id, id, app_attrs)
      orig_embedded = app_attrs["embedded"]
      app_attrs_to_internal(app_attrs)
      hash = MongoDataStore.find_and_modify({
        :query => { "_id" => user_id, "apps.name" => { "$ne" => id }, "$where" => "this.consumed_gears < this.max_gears"},
        :update => { "$push" => { "apps" => app_attrs }, "$inc" => { "consumed_gears" => 1 }} })
      app_attrs["embedded"] = orig_embedded
      raise Cloud::Sdk::UserException.new("#{user_id} has already reached the application limit", 104) if hash == nil
    end

    def self.delete_user(user_id)
      MongoDataStore.remove({ "_id" => user_id })
    end

    def self.delete_app(user_id, id)
      MongoDataStore.update({ "_id" => user_id, "apps.name" => id},
                            { "$pull" => { "apps" => {"name" => id }}, "$inc" => { "consumed_gears" => -1 }})
    end

    def self.app_attrs_to_internal(app_attrs)
      if app_attrs
        if app_attrs["embedded"]
          embedded_carts = []
          app_attrs["embedded"].each do |cart_name, cart_info|
            cart_info["framework"] = cart_name
            embedded_carts.push(cart_info)
          end
          app_attrs["embedded"] = embedded_carts
        else
          app_attrs["embedded"] = []
        end
      end
      app_attrs
    end
    
    def self.app_hash_to_ret(app_hash)
      if app_hash
        if app_hash["embedded"]
          embedded_carts = {}
          app_hash["embedded"].each do |cart_info|
            cart_name = cart_info["framework"]
            embedded_carts[cart_name] = cart_info
          end
          app_hash["embedded"] = embedded_carts
        else
          app_hash["embedded"] = {}
        end
      end
      app_hash
    end
    
    def self.apps_hash_to_apps_ret(apps_hash)
      ret = []
      apps_hash.each do |app_hash|
        ret.push(app_hash_to_ret(app_hash))
      end if apps_hash
      ret
    end
  end
end
