class RestReply < Cloud::Sdk::Model
  attr_accessor :version, :status, :type, :data, :messages, :links
  API_VERSION = "1.0"
  
  def initialize(status=nil, links=nil, type=nil, data=nil)
    self.status = status
    self.type = type
    self.data = data
    self.links = links
    self.messages = []
    self.version = API_VERSION
  end
  
  def to_xml(options={})
    options[:tag_name] = "response"
    super(options)
  end
end