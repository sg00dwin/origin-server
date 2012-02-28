require 'validators/namespace_validator'
class Domain < Cloud::Sdk::Model
  include ActiveModel::Validations
   attr_accessor :namespace
   validates :namespace, :presence => true, :namespace => true
   def initialize(namespace)
     self.namespace = namespace
   end
   
   def self.namespace_available?(namespace)
     Rails.logger.debug "Checking too see if namesspace #{namespace} is available"
     dns_service = Cloud::Sdk::DnsService.instance
     return dns_service.namespace_available?(namespace)
   end
end