class CloudUser < StickShift::UserModel
  alias :initialize_old :initialize

  def initialize(login=nil, ssh=nil, ssh_type=nil, key_name=nil, capabilities=nil, parent_user_login=nil)
    initialize_old(login, ssh, ssh_type, key_name, capabilities, parent_user_login)
  end

  def get_capabilities
    user_capabilities = self.capabilities.dup
    if self.parent_user_login
      parent_user = CloudUser.find(self.parent_user_login)
      parent_user.capabilities['inherit_on_subaccounts'].each do |cap|
        user_capabilities[cap] = parent_user.capabilities[cap] if parent_user.capabilities[cap] 
      end if parent_user && parent_user.capabilities.has_key?('inherit_on_subaccounts')
    end
    user_capabilities
  end
end
