class RestUser < Cloud::Sdk::Model
  attr_accessor :login, :links
  
  def initialize(*args)
    if args[0].class == CloudUser
      cloud_user = args[0]
      self.login = cloud_user.rhlogin
    else
      if args[0].class == Hash || args[0].class == ActiveSupport::HashWithIndifferentAccess
        app_hash = args[0]
        app_hash.each do |k,v|
          self.instance_variable_set("@#{k}",v)
        end
      else
        @login = args[0]
      end
    end
    
    @links = [
      Link.new("Get user information", "GET", "/user"),
      Link.new("Get SSH keys", "GET", "/user/keys"),
      Link.new("Add new SSH key", "POST", "/user/keys", [
        Param.new("name", "string", "Name of the application"),
        Param.new("type", "string", "Type of Key", "RSA or DSA"),
        Param.new("ssh", "string", "The key portion of an rsa key (excluding ssh-rsa and comment)"),
      ]),
    ]
  end
  
  def to_xml(options={})
    options[:tag_name] = "user"
    super(options)
  end
end
