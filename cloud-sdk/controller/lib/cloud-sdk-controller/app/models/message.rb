class Message < Cloud::Sdk::Model
  attr_accessor :severity, :text
  
  def initialize(severity=:info, text=nil)
    self.severity = severity
    self.text = text
  end
end