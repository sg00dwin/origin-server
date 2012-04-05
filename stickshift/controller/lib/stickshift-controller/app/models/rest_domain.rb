class RestDomain < StickShift::Model
  attr_accessor :id, :suffix, :links
  include LegacyBrokerHelper
  
  def initialize(domain)
    self.id = domain.namespace
    self.suffix = Rails.application.config.ss[:domain_suffix] 

    carts = get_cached("cart_list_standalone", :expires_in => 21600.seconds) do
      Application.get_available_cartridges("standalone")
    end
    
    self.links = {
      "GET" => Link.new("Get domain", "GET", "/domains/#{id}"),
      "LIST_APPLICATIONS" => Link.new("List applications", "GET", "/domains/#{id}/applications"),
      "ADD_APPLICATION" => Link.new("Create new application", "POST", "/domains/#{id}/applications", [
        Param.new("name", "string", "Name of the application"),
        Param.new("cartridge", "string", "framework-type, e.g: php-5.3", carts)
      ], [
        OptionalParam.new("scale", "boolean", "Mark application as scalable", [true, false], false),
        OptionalParam.new("node_profile", "string", "The size of the gear", ["small", "micro", "medium", "large", "exlarge", "jumbo"], "small")
      ]),
      "ADD_APPLICATION_FROM_TEMPLATE" => Link.new("Create new application", "POST", "/domains/#{id}/applications", [
        Param.new("name", "string", "Name of the application"),
        Param.new("template", "string", "UUID of the application template")
      ]),
      "UPDATE" => Link.new("Update domain", "PUT", "/domains/#{id}",[
        Param.new("domain_id", "string", "Name of the domain")
      ]),
      "DELETE" => Link.new("Delete domain", "DELETE", "/domains/#{id}",nil,[
        OptionalParam.new("force", "boolean", "Force delete domain.  i.e. delete any applications under this domain", [true, false], false)
      ])
    }
  end
  
  def to_xml(options={})
    options[:tag_name] = "domain"
    super(options)
  end
  
end
