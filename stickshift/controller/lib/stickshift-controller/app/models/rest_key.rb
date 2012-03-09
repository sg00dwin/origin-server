class RestKey < StickShift::Model
  attr_accessor :name, :content, :type, :links
  
  def initialize(name, content, type=nil)
    self.name= name
    self.content = content
    self.type = type || "ssh-rsa"

    self.links = {
      "GET" => Link.new("Get SSH key", "GET", "/user/keys/#{name}"),
      "UPDATE" => Link.new("Update SSH key", "PUT", "/user/keys/#{name}", [
        Param.new("type", "string", "Type of Key", ["ssh-rsa", "ssh-dss"]),
        Param.new("content", "string", "The key portion of an rsa key (excluding ssh-rsa and comment)"),
      ]),
      "DELETE" => Link.new("Delete SSH key", "DELETE", "/user/keys/#{name}")
    }
  end
  
  def to_xml(options={})
    options[:tag_name] = "key"
    super(options)
  end

end