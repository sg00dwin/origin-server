class RestCartridge < Cloud::Sdk::Model
  attr_accessor :type, :name
  
  def initialize(type=nil, name=nil)
    self.name = name
    self.type = type
  end

  def to_xml(options={})
    options[:tag_name] = "cartridge"
    super(options)
  end
end
