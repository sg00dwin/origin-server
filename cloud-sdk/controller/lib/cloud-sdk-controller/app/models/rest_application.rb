class RestApplication < Cloud::Sdk::Model
  attr_accessor :framework, :creation_time, :uuid, :embedded, :aliases, :name, :server_identity, :links
  
  def initialize(app)
    self.framework = app.framework
    self.name = app.name
    self.creation_time = app.creation_time
    self.uuid = app.uuid
    self.aliases = app.aliases || Array.new
    self.server_identity = app.server_identity
    self.embedded = app.embedded
  end
  
  def to_xml(options={})
    options[:tag_name] = "application"
    super(options)
  end
end