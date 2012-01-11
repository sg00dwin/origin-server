class OptionalParam < Param
  def initialize(name=nil, type=nil, default_value=nil)
    super(name, type)
    self.default_value = default_value
  end
end
