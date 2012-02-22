 require 'validators/key_validator'
 class Key < Cloud::Sdk::Model
   attr_accessor :name, :type, :content
   include ActiveModel::Validations
   validate_with KeyValidator
   def initialize(name, type, content)
     self.name = name
     self.type = type
     self.content = content
   end
 end