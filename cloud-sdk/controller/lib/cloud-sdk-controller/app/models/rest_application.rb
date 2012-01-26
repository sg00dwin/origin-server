class RestApplication < Cloud::Sdk::Model
  attr_accessor :name, :version, :display_name,
                :cartridges, :creation_time, :uuid, 
                :aliases, :links
  
  def initialize(app, domain_id)
    self.name = app.name
    self.version = app.version
    self.display_name = app.display_name
    self.cartridges = app.requires_feature
    self.creation_time = app.creation_time
    self.uuid = app.uuid
    self.aliases = app.aliases || Array.new
    self.domain_id = domain_id

    self.links = [
      Link.new("Get application", "GET", "/domains/#{@domain_id}/applications/#{@name}"),
      Link.new("Start application", "POST", "/domains/#{@domain_id}/applications/#{@name}/events", [
        Param.new("event", "string", "event", "started")
      ]),
      Link.new("Stop application", "POST", "/domains/#{@domain_id}/applications/#{@name}/events", [
        Param.new("event", "string", "event", "stopped")
      ]),      
      Link.new("Restart application", "POST", "/domains/#{@domain_id}/applications/#{@name}/events", [
        Param.new("event", "string", "event", "restarted")
      ]),
      Link.new("Force stop application", "POST", "/domains/#{@domain_id}/applications/#{@name}/events", [
        Param.new("event", "string", "event", "force-stopped")
      ]),
      Link.new("Delete application", "DELETE", "/domains/#{@domain_id}/applications/#{@name}"),
      
      Link.new("Add embedded cartridge", "POST", "/applications/#{@name}/cartridges",[
        Param.new("cartridge", "string", "framework-type, e.g.: mysql-5.1", Application.get_available_cartridges.map{|c| c.name}.join(', '))
      ])
    ]
      
    unless @requires_feature.nil?
      @embedded.each do |key, value|
        Rails.logger.debug "key=#{key} value=#{value}"
        self.links += [
          Link.new("Start embedded cartridge", "POST", "/domains/#{@domain_id}/applications/#{@name}/cartridges/#{key}/events", [
            Param.new("event", "string", "event", "started")
          ]),
          Link.new("Stop embedded cartridge", "POST", "/domains/#{@domain_id}/applications/#{@name}/cartridges/#{key}/events", [
            Param.new("event", "string", "event", "stopped")
          ]),
          Link.new("Restart embedded cartridge", "POST", "/domains/#{@domain_id}/applications/#{@name}/cartridges/#{key}/events", [
            Param.new("event", "string", "event", "restarted")
          ]),
          Link.new("Reload embedded cartridge", "POST", "/domains/#{@domain_id}/applications/#{@name}/cartridges/#{key}/events", [
            Param.new("event", "string", "event", "reloaded")
          ])
        ]
      end
    end
  end
  
  def to_xml(options={})
    options[:tag_name] = "application"
    super(options)
  end
end
