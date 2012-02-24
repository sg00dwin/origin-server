Cloud::Sdk::AuthService.provider=Express::Broker::AuthService
Cloud::Sdk::DataStore.provider=Express::Broker::MongoDataStore
Cloud::Sdk::ApplicationContainerProxy.provider=Express::Broker::ApplicationContainerProxy
Cloud::Sdk::DnsService.provider=Express::Broker::DnsService
ApplicationObserver.instance
CloudUserObserver.instance

#customizations to models
require 'cloud_user_ext'