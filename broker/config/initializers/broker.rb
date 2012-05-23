StickShift::DataStore.provider=Express::Broker::MongoDataStore
ApplicationObserver.instance
CloudUserObserver.instance
DomainObserver.instance
#customizations to models
require 'cloud_user_ext' 

if Rails.application.config.datastore[:replica_set]
  MongoMapper.connection = Mongo::ReplSetConnection.new(*Rails.application.config.datastore[:host_port] << {:read => :secondary})
else
  MongoMapper.connection = Mongo::Connection.new(Rails.application.config.datastore[:host_port][0], Rails.application.config.datastore[:host_port][1])
end
MongoMapper.database = Rails.application.config.datastore[:db]
MongoMapper.connection[Rails.application.config.datastore[:db]].authenticate(Rails.application.config.datastore[:user], Rails.application.config.datastore[:password]) if Rails.application.config.datastore[:user]
