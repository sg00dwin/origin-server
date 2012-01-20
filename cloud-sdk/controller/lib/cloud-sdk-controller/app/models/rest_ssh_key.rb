class RestSshKey < Cloud::Sdk::Model
  attr_accessor :name, :ssh, :links
  
  def initialize(name=nil, ssh=nil)
    self.name= name
    self.ssh = ssh

    self.links = [
      Link.new("Get SSH key", "GET", "/user/keys/#{name}"),
      Link.new("Update SSH key", "PUT", "/user/keys/#{name}", [
        Param.new("name", "string", "Name of the application"),
        Param.new("type", "string", "Type of Key", "RSA or DSA"),
        Param.new("ssh", "string", "The key portion of an rsa key (excluding ssh-rsa and comment)"),
      ]),
      Link.new("Delete SSH key", "DELETE", "/user/keys/#{name}")
    ]
  end
  
  def to_xml(options={})
    options[:tag_name] = "ssh-key"
    super(options)
  end

end