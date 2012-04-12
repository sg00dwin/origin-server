StickShift::DataStore.provider=Express::Broker::MongoDataStore
ProfilerObserver.instance
ApplicationObserver.instance
CloudUserObserver.instance

#customizations to models
require 'cloud_user_ext'
