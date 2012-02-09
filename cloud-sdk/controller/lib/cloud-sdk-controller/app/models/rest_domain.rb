class RestDomain < Cloud::Sdk::Model
  attr_accessor :namespace, :ssh, :links
  include LegacyBrokerHelper
  
  def initialize(namespace=nil, ssh=nil)
    self.namespace = namespace
    self.ssh = ssh

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
      "CREATE" => Link.new("Create new domain", "POST", "/domains", [
        Param.new("namespace", "string", "Name of the domain"),
        Param.new("ssh", "string", "The key portion of an rsa key (excluding ssh-rsa and comment)")
      ]),
      "UPDATE" => Link.new("Update domain", "PUT", "/domains/#{namespace}",[
        Param.new("namespace", "string", "Name of the domain"),
        Param.new("ssh", "string", "The key portion of an rsa key (excluding ssh-rsa and comment)")
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
