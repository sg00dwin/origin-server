class RestApplication < Cloud::Sdk::Model
  attr_accessor :framework, :creation_time, :uuid, :embedded, :aliases, :name, :links, :domain_id
  include LegacyBrokerHelper
  
  def initialize(app, domain_id)
    self.framework = app.framework
    self.name = app.name
    self.creation_time = app.creation_time
    self.uuid = app.uuid
    self.aliases = app.aliases || Array.new
    self.embedded = app.embedded
    self.domain_id = domain_id

    cart_type = "embedded"
    cache_key = "cart_list_#{cart_type}"
    carts = get_cached(cache_key, :expires_in => 21600.seconds) do
      Application.get_available_cartridges("embedded")
    end

    self.links = {
      "GET" => Link.new("Get application", "GET", "/domains/#{@domain_id}/applications/#{@name}"),
      "GET" => Link.new("Get application descriptor", "GET", "/domains/#{@domain_id}/applications/#{@name}/descriptor"),      
      "GET" => Link.new("Get application gears", "GET", "/domains/#{@domain_id}/applications/#{@name}/gears"),      
      "START" => Link.new("Start application", "POST", "/domains/#{@domain_id}/applications/#{@name}/events", [
        Param.new("event", "string", "event", "start")
      ]),
      "STOP" => Link.new("Stop application", "POST", "/domains/#{@domain_id}/applications/#{@name}/events", [
        Param.new("event", "string", "event", "stop")
      ]),      
      "RESTART" => Link.new("Restart application", "POST", "/domains/#{@domain_id}/applications/#{@name}/events", [
        Param.new("event", "string", "event", "restart")
      ]),
      "FORCE_STOP" => Link.new("Force stop application", "POST", "/domains/#{@domain_id}/applications/#{@name}/events", [
        Param.new("event", "string", "event", "force-stop")
      ]),
      "DELETE" => Link.new("Delete application", "DELETE", "/domains/#{@domain_id}/applications/#{@name}"),
      
      "ADD_CARTRIDGE" => Link.new("Add embedded cartridge", "POST", "/domains/#{@domain_id}/applications/#{@name}/cartridges",[
        Param.new("cartridge", "string", "framework-type, e.g.: mysql-5.1", carts)
      ]),
      "LIST_CARTRIDGES" => Link.new("List embedded cartridges", "GET", "/domains/#{@domain_id}/applications/#{@name}/cartridges")
    }
  end
  
  def to_xml(options={})
    options[:tag_name] = "application"
    super(options)
  end
end
