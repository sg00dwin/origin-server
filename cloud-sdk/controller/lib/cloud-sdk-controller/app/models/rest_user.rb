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
      Link.new("API entry point", "GET", "/api"),
      Link.new("Get user information", "GET", "/user"),
    ]
  end
  
  def to_xml(options={})
    options[:tag_name] = "user"
    super(options)
  end
end
