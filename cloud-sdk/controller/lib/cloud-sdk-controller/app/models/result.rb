class Result
  API_VERSION = "1.0"
  def initialize(status=nil, type=nil, data=nil)
    self.status = status
    self.type = type
    self.data = data
    self.messages = Array.new
    self.version = API_VERSION
  end
end