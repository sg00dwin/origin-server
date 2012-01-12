class RestDomain < Cloud::Sdk::Model
  attr_accessor :namespace, :ssh, :links
  def initialize(namespace=nil, ssh=nil, links=nil)
    self.namespace = namespace
    self.ssh = ssh
    self.links = links || Array.new
  end
  
  def to_xml(options={})
    options[:tag_name] = "domain"
    super(options)
  end
  
end