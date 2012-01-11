class Param
  def initialize(name=nil, type=nil, description=nil, valid_options=nil)
    self.name = name
    self.type = type
    self.description = description
    self.valid_options = valid_options
  end
end