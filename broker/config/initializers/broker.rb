StickShift::AuthService.provider=Express::Broker::AuthService
StickShift::DataStore.provider=Express::Broker::MongoDataStore
StickShift::ApplicationContainerProxy.provider=Express::Broker::ApplicationContainerProxy
ApplicationObserver.instance
CloudUserObserver.instance

#customizations to models
require 'cloud_user_ext'
