class Message < Cloud::Sdk::Model
  attr_accessor :severity, :text, :exit_code, :attribute
  
  def initialize(severity=:info, text=nil, exit_code=nil, attribute=nil)
    self.severity = severity
    self.text = text
    self.exit_code = exit_code
    self.attribute = attribute
  end
end