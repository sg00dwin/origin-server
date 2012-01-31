class ApplicationContainer < Cloud::Sdk::Cartridge
  attr_accessor :uuid, :uid, :server_id, :group_inst_id, :node_profile, :container, :app
  primary_key :uuid
  exclude_attributes :container, :app
  
  def initialize(app, node_profile=nil, uuid=nil, uid=nil)
    self.app = app
    @uuid = uuid || Cloud::Sdk::Model.gen_uuid
    self.node_profile = node_profile
    get_proxy
  end
  
  def get_proxy
    if self.container.nil? and !@server_id.nil?
      self.container = Cloud::Sdk::ApplicationContainerProxy.instance(@server_id)
    end    
    return self.container
  end
  
  def create
    if server_id.nil?
      self.container = Cloud::Sdk::ApplicationContainerProxy.find_available(self.node_profile)
      self.server_id = self.container.id
      self.uid = self.container.reserve_uid
      return self.container.create(app,self)
    end
  end
  
  def destroy
    unless container.nil?
      container.destroy(app,self)
    end
  end
end