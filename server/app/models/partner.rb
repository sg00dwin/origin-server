class Partner
  
  attr_accessor :name, :id, :summary, :url, :logo, :contact, :quote, :quote_attr, :description, :advantage, :availability, :category, :availability_category
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end
