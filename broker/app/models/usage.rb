class Usage < StickShift::Model
  
attr_accessor :uuid, :gear_uuid, :gear_type, :time, :action
  primary_key :uuid

  def initialize()
  end
end