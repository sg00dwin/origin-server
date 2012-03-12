class RestEstimates < StickShift::Model
  attr_accessor :links 
 
  def initialize
    self.links = {
      "GET_APPLICATION" => Link.new("Get application estimate", "GET", "/estimates/application", [
        Param.new("descriptor", "string", "application requirements")
      ]) 
    }
  end
  
  def to_xml(options={})
    options[:tag_name] = "estimates"
    super(options)
  end
end
