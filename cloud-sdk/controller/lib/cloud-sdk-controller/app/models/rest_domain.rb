class RestDomain < Cloud::Sdk::Model
  attr_accessor :namespace, :ssh, :links
  def initialize(namespace=nil, ssh=nil)
    self.namespace = namespace
    self.ssh = ssh

    carts = []
    #get_cached("cart_list_standalone", :expires_in => 21600.seconds) do
    #  Application.get_available_cartridges("standalone")
    #end
    
    self.links = [
      Link.new("Get domain", "GET", "/domains/#{namespace}"),
      Link.new("List applications", "GET", "/domains/#{namespace}/applications"),
      Link.new("Create new application", "POST", "/applications", [
        Param.new("name", "string", "Name of the application"),
        Param.new("cartridge", "string", "framework-type, e.g: php-5.3", carts.join(', '))
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