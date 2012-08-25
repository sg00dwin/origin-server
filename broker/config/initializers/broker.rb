StickShift::DataStore.provider=Express::Broker::MongoDataStore
ApplicationObserver.instance
CloudUserObserver.instance
DomainObserver.instance
#customizations to models
require 'cloud_user_ext' 

# Extend mcollective with express specific extensions
require File.expand_path('../../lib/express/broker/mcollective_ext', File.dirname(__FILE__))

if Rails.application.config.datastore[:replica_set]
  MongoMapper.connection = Mongo::ReplSetConnection.new(*Rails.application.config.datastore[:host_port] << {:read => :secondary})
else
  MongoMapper.connection = Mongo::Connection.new(Rails.application.config.datastore[:host_port][0], Rails.application.config.datastore[:host_port][1])
end
MongoMapper.database = Rails.application.config.datastore[:db]
MongoMapper.connection[Rails.application.config.datastore[:db]].authenticate(Rails.application.config.datastore[:user], Rails.application.config.datastore[:password]) if Rails.application.config.datastore[:user]
  
  
db = StickShift::DataStore.instance.db
distributed_lock_collection = db.collection(Rails.application.config.datastore[:collections][:distributed_lock])
distributed_lock_collection.ensure_index([["type", Mongo::ASCENDING]], {:unique => true})

#district_collection = db.collection(Rails.application.config.datastore[:collections][:district])
#district_collection.ensure_index([["available_capacity", Mongo::ASCENDING]])
