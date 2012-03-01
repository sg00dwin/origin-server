require 'rubygems'
require 'mongo'
require 'pp'

module StickShift
  class MongoDataStore < DataStore
    @ss_ds_provider = StickShift::MongoDataStore
    MAX_CON_RETRIES   = 60
    CON_RETRY_WAIT_TM = 0.5 # in secs
 
    def self.provider=(provider_class)
      @ss_ds_provider = provider_class
    end
    
    def self.instance
      @ss_ds_provider.new
    end
    
    def find(obj_type, user_id, id)
      Rails.logger.debug "MongoDataStore.find(#{obj_type}, #{user_id}, #{id})\n\n"
      case obj_type
      when "CloudUser"
	      MongoDataStore.get_user(user_id)
      when "Application"
	      MongoDataStore.get_app(user_id, id)
	    when "ApplicationTemplate"
	      MongoDataStore.find_application_template(id)
      end
    end
    
    def find_all(obj_type, user_id=nil, f=nil)
      Rails.logger.debug "MongoDataStore.find_all(#{obj_type}, #{user_id}, #{f})\n\n"
      case obj_type
      when "CloudUser"
	      MongoDataStore.get_users
      when "Application"
	      MongoDataStore.get_apps(user_id)
	    when "ApplicationTemplate"
	      if f.nil? || f.empty?
	        MongoDataStore.find_all_application_templates()
	      else
	        MongoDataStore.find_application_template_by_tag(f[:tag])
        end
      end
    end
    
    def find_by_uuid(obj_type_of_uuid, uuid)
      Rails.logger.debug "MongoDataStore.find_by_uuid(#{obj_type_of_uuid}, #{uuid})\n\n"
      case obj_type_of_uuid
      when "CloudUser"
        MongoDataStore.get_user_by_uuid(uuid)
      when "Application"
        MongoDataStore.get_user_by_app_uuid(uuid)
	    when "ApplicationTemplate"
	      MongoDataStore.find_application_template(uuid)
      end
    end
    
    def save(obj_type, user_id, id, obj_attrs)
      #Rails.logger.debug "MongoDataStore.save(#{obj_type}, #{user_id}, #{id}, #{obj_attrs.pretty_inspect})\n\n"
      Rails.logger.debug "MongoDataStore.save(#{obj_type}, #{user_id}, #{id}, #hidden)\n\n"
      case obj_type
      when "CloudUser"
	      MongoDataStore.put_user(user_id, obj_attrs)
      when "Application"
	      MongoDataStore.put_app(user_id, id, obj_attrs)
      end
    end
    
    def create(obj_type, user_id, id, obj_attrs)
      Rails.logger.debug "MongoDataStore.create(#{obj_type}, #{user_id}, #{id}, #{obj_attrs.pretty_inspect})\n\n"
      Rails.logger.debug "MongoDataStore.create(#{obj_type}, #{user_id}, #{id}, #hidden)\n\n"      
      case obj_type
      when "CloudUser"
        MongoDataStore.add_user(user_id, obj_attrs)
      when "Application"
        MongoDataStore.add_app(user_id, id, obj_attrs)
	    when "ApplicationTemplate"
	      MongoDataStore.save_application_template(id, obj_attrs)
      end
    end
    
    def delete(obj_type, user_id, id=nil)
      Rails.logger.debug "MongoDataStore.delete(#{obj_type}, #{user_id}, #{id})\n\n"
      case obj_type
      when "CloudUser"
	      MongoDataStore.delete_user(user_id)
      when "Application"
	      MongoDataStore.delete_app(user_id, id)
	    when "ApplicationTemplate"
	      MongoDataStore.delete_application_template(id)	      
      end
    end

    private
    
    def self.find_application_template_by_tag(tag)
      arr = MongoDataStore::application_template_collection.find( {"tags" => tag} )
      return nil if arr.nil?
      templates = []
      arr.each do |hash|
        hash.delete("_id")
        templates.push(hash)
      end
      templates
    end
    
    def self.find_application_template(id)
      hash = MongoDataStore::application_template_collection.find_one( {"_id" => id} )        
      return nil if hash.nil?
      hash.delete("_id")
      hash
    end
    
    def self.find_all_application_templates()
      arr = MongoDataStore::application_template_collection.find()
      return nil if arr.nil?
      templates = []
      arr.each do |hash|
        hash.delete("_id")
        templates.push(hash)
      end
      templates
    end
    
    def self.save_application_template(uuid, attrs)
      Rails.logger.debug "MongoDataStore.save_application_template(#{uuid}, #{attrs.pretty_inspect})\n\n"
      attrs["_id"] = uuid
      MongoDataStore.application_template_collection.update({ "_id" => uuid }, attrs, { :upsert => true })
      attrs.delete("_id")
    end
    
    def self.delete_application_template(uuid)
      Rails.logger.debug "MongoDataStore.delete_application_template(#{uuid})\n\n"
      MongoDataStore.application_template_collection.remove({ "_id" => uuid })
    end
    
    def self.application_template_collection
      MongoDataStore.db.collection(Rails.configuration.datastore_mongo[:collections][:application_template])
    end

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
      if Rails.configuration.ss[:datastore_mongo][:replica_set]
        con = Mongo::ReplSetConnection.new(*Rails.configuration.ss[:datastore_mongo][:host_port] \
                                           << {:read => :secondary})
      else
        con = Mongo::Connection.new(Rails.configuration.ss[:datastore_mongo][:host_port][0], 
                                    Rails.configuration.ss[:datastore_mongo][:host_port][1])
      end
      user_db = con.db(Rails.configuration.ss[:datastore_mongo][:db])
      user_db.authenticate(Rails.configuration.ss[:datastore_mongo][:user],
                           Rails.configuration.ss[:datastore_mongo][:password])
      user_db
    end

    def self.collection
      MongoDataStore.db.collection(Rails.configuration.ss[:datastore_mongo][:collections][:user])
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
    
    def self.get_user_by_uuid(uuid)
      hash = MongoDataStore.find_one( "uuid" => uuid )
      return nil unless hash && !hash.empty?
      
      user_hash_to_ret(hash)
    end
    
    def self.get_user_by_app_uuid(uuid)
      hash = MongoDataStore.find_one( "apps.uuid" => uuid )
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
      app_attrs_to_internal(app_attrs)
      MongoDataStore.update({ "_id" => user_id, "apps.name" => id}, { "$set" => { "apps.$" => app_attrs }} )
    end

    def self.add_app(user_id, id, app_attrs)
      app_attrs_to_internal(app_attrs)
      hash = MongoDataStore.find_and_modify({
        :query => { "_id" => user_id, "apps.name" => { "$ne" => id }, "$where" => "this.consumed_gears < this.max_gears"},
        :update => { "$push" => { "apps" => app_attrs }, "$inc" => { "consumed_gears" => 1 }} })
      raise StickShift::UserException.new("#{user_id} has already reached the application limit", 104) if hash == nil
    end

    def self.delete_user(user_id)
      MongoDataStore.remove({ "_id" => user_id })
    end

    def self.delete_app(user_id, id)
      MongoDataStore.update({ "_id" => user_id, "apps.name" => id},
                            { "$pull" => { "apps" => {"name" => id }}, "$inc" => { "consumed_gears" => -1 }})
    end

    def self.app_attrs_to_internal(app_attrs)
      app_attrs
    end
    
    def self.app_hash_to_ret(app_hash)
      app_hash
    end
    
    def self.apps_hash_to_apps_ret(apps_hash)
      ret = []
      ret = apps_hash.map { |app_hash| app_hash_to_ret(app_hash) } if apps_hash
      ret
    end
  end
end
