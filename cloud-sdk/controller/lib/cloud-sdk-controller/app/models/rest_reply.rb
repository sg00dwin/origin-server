class RestReply < Cloud::Sdk::Model
  attr_accessor :status, :type, :data, :messages, :version
  API_VERSION = "1.0"
  
  def initialize(status=nil, type=nil, data=nil)
    self.status = status
    self.type = type
    self.data = data
    self.messages = Array.new
    self.version = API_VERSION
  end
  
  def to_xml(options={})
    options[:root] ||= "response"
    super(options)
  end
end