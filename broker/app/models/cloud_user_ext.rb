class CloudUser < StickShift::UserModel
  attr_accessor :vip
  alias :initialize_old :initialize
  
  def initialize(login=nil, ssh=nil, namespace=nil, ssh_type=nil, key_name=nil)
    self.vip = false
    initialize_old(login, ssh, namespace, ssh_type, key_name)
  end
end