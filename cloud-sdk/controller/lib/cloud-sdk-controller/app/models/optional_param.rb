class OptionalParam < Param
  def initialize(name=nil, type=nil, description=nil, valid_options=nil, default_value=nil)
    super(name, type, description, valid_options)
    self.default_value = default_value
  end
end
