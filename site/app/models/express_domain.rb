class ExpressDomain
  
  include ActiveModel::Validations
  include ActiveModel::Serialization
  include ExpressApi
  
  attr_accessor :namespace, :ssh, :alter
  
end
