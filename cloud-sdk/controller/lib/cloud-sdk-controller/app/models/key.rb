 class Key < Cloud::Sdk::UserModel
   attr_accessor :name, :type, :content
   include KeyValidator
   
   def initialize(name, type, content)
     self.name = name
     self.type = type
     self.content = content
   end
   

 end