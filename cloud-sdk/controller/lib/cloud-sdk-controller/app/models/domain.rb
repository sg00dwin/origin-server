class Domain < Cloud::Sdk::Model
  attr_accessor :namespace, :ssh
  def initialize(namespace=nil, ssh=nil)
    self.namespace = namespace
    self.ssh = ssh
  end
end