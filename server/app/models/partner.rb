class Partner
  
  attr_accessor :name, :id, :blurb, :url, :logo
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
end