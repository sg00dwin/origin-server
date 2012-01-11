class Message   
  def initialize(severity=info, text=nil)
    self.severity = severity
    self.text = text
  end
end