class Partner
  
  attr_accessor :name, :id, :summary, :url, :logo, :contact, :quote, :quote_attr, :description, :advantage, :availability
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end
