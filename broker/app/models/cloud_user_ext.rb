class CloudUser < StickShift::UserModel
  attr_accessor :vip
  alias :initialize_old :initialize

  def initialize(login=nil, ssh=nil, ssh_type=nil, key_name=nil ,capabilities=nil ,parent_user_login=nil)
    self.vip = false
    initialize_old(login, ssh, ssh_type, key_name, capabilities, parent_user_login)
  end
end
