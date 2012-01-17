module Cloud::Sdk
  class GroupInstance < Cloud::Sdk::UserModel
    attr_accessor :gear_ids, :node_profile, :component_instances
  end
end