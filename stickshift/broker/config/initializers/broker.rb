require 'lib/stickshift/broker/application_container_proxy'
require 'lib/stickshift/broker/bind_dns_service'
require 'lib/stickshift/broker/mongo_auth_service'

StickShift::AuthService.provider=StickShift::AuthService
StickShift::DataStore.provider=StickShift::MongoDataStore
StickShift::ApplicationContainerProxy.provider=StickShift::Broker::ApplicationContainerProxy
StickShift::DnsService.provider=StickShift::DnsService
