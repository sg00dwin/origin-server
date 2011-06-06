class ExpressDomain
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming
  
  include ExpressApi
  
  attr_accessor :namespace, :ssh, :alter
  
  validates_presence_of :rhlogin
  validates :password, :presence => true,
                       :length => {:minimum => 6} 
  
  validates :namespace, :presence => true,
                        :length => {:maximum => 16},
                        :format => {:with => /^[A-Za-z0-9]+$/}
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def create!
    @alter = false
    self.save!
  end
  
  def update!
    @alter = true
    self.save!
  end
  
  protected 
  def save!
    json_data = self.to_json(:except => :password)
    http_post(@@domain_url) do |json_response|
      yield json_response if block_given?
    end
  end
  
end
