class GroupInstance < Cloud::Sdk::UserModel
  attr_accessor :app, :gears, :node_profile, :component_instances, 
    :name, :cart_name, :profile_name, :group_name, :reused_by
  exclude_attributes :app

  def initialize(app, cartname=nil, profname=nil, groupname=nil, path=nil)
    self.app = app
    self.name = path
    self.cart_name = cartname
    self.profile_name = profname
    self.component_instances = []
    self.group_name = groupname
    self.reused_by = []
  end

  def merge(ginst)
    reused = [self.name, self.cart_name, self.profile_name, self.group_name]
    self.reused_by << reused
    self.name = ginst.name
    self.cart_name = ginst.cart_name
    self.profile_name = ginst.profile_name
    self.group_name = ginst.group_name
    self.component_instances = (self.component_instances + ginst.component_instances).uniq unless ginst.component_instances.nil?
    if not ginst.gears.nil?
      self.gears = [] if self.gears.nil?
      self.gears = self.gears + ginst.gears
    end
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
  
  def gears=(data)
    @gears = [] if @gears.nil?
    data.each do |hash|
      if hash.class == Gear
        @gears.push hash
      else
        gear = Gear.new(@app)
        gear.attributes=hash
      @gears.push gear
      end                             
    end                               
  end

  def elaborate(group, parent_comp_path, app)
    group_inst_hash = {}
    group.component_refs.each { |comp_ref|
      cpath = (parent_comp_path.empty? ? "" : parent_comp_path + ".") + self.cart_name + "." + comp_ref.name
      ci = app.comp_instance_map[cpath]
      ci = ComponentInstance.new(self.cart_name, self.profile_name, self.group_name, comp_ref.name, cpath, self) if ci.nil?
      self.component_instances << cpath if not self.component_instances.include? cpath
      app.comp_instance_map[cpath] = ci
      app.working_comp_inst_hash[cpath] = ci
      comp_groups = ci.elaborate(app)
      group_inst_hash[comp_ref.name] = comp_groups
    }
    
    # TODO: For FUTURE : if one wants to optimize by merging the groups
    # then pick group_inst_hash and merge them up
    # e.g. first component needs 4 groups, second one needs 3
    #   then, make the first three groups of first component also contain
    #   the second component and discard the second component's 3 groups
    #    (to remove groups, erase them from app.comp_instance_map for sure)

    # remove any entries in component_instances that are not part of 
    # application's working component instance hash, because that indicates
    # deleted components
    self.component_instances.delete_if { |cpath| app.working_comp_inst_hash[cpath].nil? }
  end
end
