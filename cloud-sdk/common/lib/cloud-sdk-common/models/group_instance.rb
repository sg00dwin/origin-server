module Cloud::Sdk
  class GroupInstance < Cloud::Sdk::UserModel
    attr_accessor :gear_ids, :node_profile, :component_instances, :name


    def initialize(cartname, profname, path)
      self.name = path
      self.cart_name = cartname
      self.profile_name = profname
      self.component_instances = []
    end

    def elaborate(group, parent_comp_path, app)
      group_inst_hash = {}
      group.component_refs.each { |comp|
        cpath = parent_comp_path + "." + self.cart_name + ":" + self.profile_name + "." + comp.name
        ci = ComponentInstance.new(self.cart_name, self.profile_name, cpath, self)
        self.component_instances << cpath
        app.comp_instance_map[cpath] = ci
        comp_groups = ci.elaborate(app)
        group_inst_hash[comp.name] = comp_groups
      }
      # TODO: For FUTURE : if one wants to optimize by merging the groups
      # then pick group_inst_hash and merge them up
      # e.g. first component needs 4 groups, second one needs 3
      #   then, make the first three groups of first component also contain
      #   the second component and discard the second component's 3 groups
      #    (to remove groups, erase them from app.comp_instance_map for sure)
    end
  end
end
