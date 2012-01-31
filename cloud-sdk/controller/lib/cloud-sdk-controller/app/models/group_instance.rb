class GroupInstance < Cloud::Sdk::UserModel
  attr_accessor :application_containers, :node_profile, :component_instances, 
    :name, :cart_name, :profile_name, :group_name, :reused_by


  def initialize(cartname=nil, profname=nil, groupname=nil, path=nil)
    self.name = path
    self.cart_name = cartname
    self.profile_name = profname
    self.component_instances = []
    self.group_name = groupname
    self.reused_by = []
  end

  def merge(cartname, profname, groupname, path, comp_instance_list=nil)
    reused = [self.name, self.cart_name, self.profile_name, self.group_name]
    self.reused_by << reused
    self.name = path
    self.cart_name = cartname
    self.profile_name = profname
    self.group_name = groupname
    self.component_instances = (self.component_instances + comp_instance_list).uniq unless comp_instance_list.nil?
    # component_instances remains a flat collection
  end
  
  def application_containers=(data)
    @application_containers = [] if @application_containers.nil?
    data.each do |hash|
      if hash.class == ApplicationContainer
        @application_containers.push hash
      else
        application_container = ApplicationContainer.new(self)
        application_container.attributes=hash
      @application_containers.push application_container
      end                             
    end                               
  end

  def elaborate(group, parent_comp_path, app)
    group_inst_hash = {}
    group.component_refs.each { |comp_ref|
      cpath = (parent_comp_path.empty? ? "" : parent_comp_path + ".") + self.cart_name + "." + comp_ref.name
      ci = ComponentInstance.new(self.cart_name, self.profile_name, self.group_name, comp_ref.name, cpath, self)
      self.component_instances << cpath
      app.comp_instance_map[cpath] = ci
      comp_groups = ci.elaborate(app)
      group_inst_hash[comp_ref.name] = comp_groups
    }
    
    # TODO: For FUTURE : if one wants to optimize by merging the groups
    # then pick group_inst_hash and merge them up
    # e.g. first component needs 4 groups, second one needs 3
    #   then, make the first three groups of first component also contain
    #   the second component and discard the second component's 3 groups
    #    (to remove groups, erase them from app.comp_instance_map for sure)
  end
end
