require 'lib/stickshift/broker/application_container_proxy.rb'

StickShift::AuthService.provider=StickShift::AuthService
StickShift::DataStore.provider=StickShift::MongoDataStore
StickShift::ApplicationContainerProxy.provider=StickShift::Broker::ApplicationContainerProxy
StickShift::DnsService.provider=StickShift::BindDnsService
