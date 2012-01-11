class Link
  def initialize(method=nil, href=nil)
    self.method = method
    self.href = href
    self.required_params = Array.new
    self.optional_params = Array.new
  end
end