class Domain < Cloud::Sdk::Model
  include NamespaceValidator
   attr_accessor :namespace
   validates :namespace => true
   def initialize(namespace)
     self.namespace = namespace
   end
end