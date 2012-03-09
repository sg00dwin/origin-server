class RestCartridge < StickShift::Model
  attr_accessor :type, :name, :links
  
  def initialize(type, name, app_id=nil, domain_id=nil)
    self.name = name
    self.type = type
    if type == "embedded" and not app_id.nil? and not domain_id.nil?
      self.links = {
          "GET" => Link.new("Get embedded cartridge", "GET", "/domains/#{domain_id}/applications/#{app_id}/cartridges/#{name}"),
          "START" => Link.new("Start embedded cartridge", "POST", "/domains/#{domain_id}/applications/#{app_id}/cartridges/#{name}/events", [
            Param.new("event", "string", "event", "start")
          ]),
          "STOP" => Link.new("Stop embedded cartridge", "POST", "/domains/#{domain_id}/applications/#{app_id}/cartridges/#{name}/events", [
            Param.new("event", "string", "event", "stop")
          ]),
          "RESTART" => Link.new("Restart embedded cartridge", "POST", "/domains/#{domain_id}/applications/#{app_id}/cartridges/#{name}/events", [
            Param.new("event", "string", "event", "restart")
          ]),
          "RELOAD" => Link.new("Reload embedded cartridge", "POST", "/domains/#{domain_id}/applications/#{app_id}/cartridges/#{name}/events", [
            Param.new("event", "string", "event", "reload")
          ]),
          "DELETE" => Link.new("Delete embedded cartridge", "DELETE", "/domains/#{domain_id}/applications/#{app_id}/cartridges/#{name}")
        }
    end
  end

  def to_xml(options={})
    options[:tag_name] = "cartridge"
    super(options)
  end
end
