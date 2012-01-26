class RestDomain < Cloud::Sdk::Model
  attr_accessor :namespace, :links
  include LegacyBrokerHelper
  
  def initialize(namespace=nil)
    self.namespace = namespace
    
    self.links = [
      Link.new("Get domain", "GET", "/domains/#{namespace}"),
      Link.new("List applications", "GET", "/domains/#{namespace}/applications"),
      Link.new("Create new application", "POST", "/domains/#{namespace}/applications", [
        Param.new("name", "string", "Name of the application"),
        Param.new("cartridge", "string", "framework-type, e.g: php-5.3", Application.get_available_cartridges.map{|c| c.name}.join(', '))
      ]),
      Link.new("Delete domain", "DELETE", "/domains/#{namespace}",nil,[
        OptionalParam.new("force", "boolean", "Force delete domain.  i.e. delete any applications under this domain", "true or false", false)
      ])
    ]
  end
  
  def to_xml(options={})
    options[:tag_name] = "domain"
    super(options)
  end
  
end
