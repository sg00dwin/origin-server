require 'validators/namespace_validator'
class Domain < Cloud::Sdk::Model
  include ActiveModel::Validations
   attr_accessor :namespace
   validates :namespace, :presence => true, :namespace => true
   def initialize(namespace)
     self.namespace = namespace
   end
end