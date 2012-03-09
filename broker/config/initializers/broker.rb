StickShift::AuthService.provider=Express::Broker::AuthService
StickShift::DataStore.provider=Express::Broker::MongoDataStore
StickShift::ApplicationContainerProxy.provider=Express::Broker::ApplicationContainerProxy
StickShift::DnsService.provider=Express::Broker::DnsService
ApplicationObserver.instance
CloudUserObserver.instance

#customizations to models
require 'cloud_user_ext'