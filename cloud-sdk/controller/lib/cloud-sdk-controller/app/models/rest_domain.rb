class RestDomain < Cloud::Sdk::Model
  attr_accessor :namespace, :links
  include LegacyBrokerHelper
  
  def initialize(namespace=nil)
    self.namespace = namespace

    carts = get_cached("cart_list_standalone", :expires_in => 21600.seconds) do
      Application.get_available_cartridges("standalone")
    end
    
    self.links = {
      "GET" => Link.new("Get domain", "GET", "/domains/#{namespace}"),
      "LIST_APPLICATIONS" => Link.new("List applications", "GET", "/domains/#{namespace}/applications"),
      "ADD_APPLICATION" => Link.new("Create new application", "POST", "/domains/#{namespace}/applications", [
        Param.new("name", "string", "Name of the application"),
        Param.new("cartridge", "string", "framework-type, e.g: php-5.3", carts)
      ]),
      "ADD_APPLICATION_FROM_TEMPLATE" => Link.new("Create new application", "POST", "/domains/#{namespace}/applications", [
        Param.new("name", "string", "Name of the application"),
        Param.new("template", "string", "UUID of the application template")
      ]),
      "CREATE" => Link.new("Create new domain", "POST", "/domains", [
        Param.new("namespace", "string", "Name of the domain")
      ]),
      "UPDATE" => Link.new("Update domain", "PUT", "/domains/#{namespace}",[
        Param.new("namespace", "string", "Name of the domain")
      ]),
      "DELETE" => Link.new("Delete domain", "DELETE", "/domains/#{namespace}",nil,[
        OptionalParam.new("force", "boolean", "Force delete domain.  i.e. delete any applications under this domain", "true or false", false)
      ])
    }
  end
  
  def to_xml(options={})
    options[:tag_name] = "domain"
    super(options)
  end
  
end
