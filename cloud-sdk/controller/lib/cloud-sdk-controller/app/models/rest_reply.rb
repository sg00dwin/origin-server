class RestReply < Cloud::Sdk::Model
  attr_accessor :version, :status, :type, :data, :messages
  API_VERSION = "1.0"
  
  def initialize(status=nil, type=nil, data=nil)
    self.status = status
    self.type = type
    self.data = data
    self.messages = []
    self.version = API_VERSION
  end
  
  def process_result_io(result_io)
    unless result_io.nil?
      messages.push(Message.new(:debug, result_io.debugIO.string)) unless result_io.debugIO.string.empty?
      messages.push(Message.new(:info, result_io.messageIO.string)) unless result_io.messageIO.string.empty?
      messages.push(Message.new(:error, result_io.errorIO.string)) unless result_io.errorIO.string.empty?
      messages.push(Message.new(:result, result_io.resultIO.string)) unless result_io.resultIO.string.empty?    
    end
  end
  
  def to_xml(options={})
    options[:tag_name] = "response"
    super(options)
  end
end