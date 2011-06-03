class ExpressDomain
  
  include ActiveModel::Validations
  include ActiveModel::Serializers::JSON
  include ExpressAPI
  
  attr_accessor :namespace, :ssh, :alter
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def save!
    json_data = self.to_json(:except => :password)
    http_post(@@domain_url) do |json_response|
      yield json_response if block_given?
    end
  end
  
end
