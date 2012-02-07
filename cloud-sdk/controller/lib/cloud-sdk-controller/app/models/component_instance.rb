class ComponentInstance < Cloud::Sdk::UserModel
  attr_accessor :state, :parent_cart_name, :parent_cart_profile, :parent_component_name, :parent_cart_group,
                :name, :dependencies, :group_instance_name
  
  state_machine :state, :initial => :not_created do
    event(:create) { transition :not_created => :creating }
    event(:create_complete) { transition :creating => :stopped }
    event(:create_error) { transition :creating => :destroying }
    event(:start) { transition :stopped => :starting }
    event(:start_error) { transition :starting => :stopped }
    event(:start_complete) { transition :starting => :running }
    event(:stop) { transition :running => :stopping }
    event(:stop_error) { transition :stopping => :running }
    event(:stop_complete) { transition :stopping => :stopped }
    event(:destroy) { transition :stopped => :destroying }
    event(:destroy_complete) { transition :destroying => :not_created }
  end

  def initialize (cartname=nil, profname=nil, groupname=nil, compname=nil, pathname=nil, gi=nil)
    self.name = pathname
    self.parent_cart_name = cartname
    self.parent_cart_profile = profname
    self.parent_cart_group = groupname
    self.group_instance_name = gi.name unless gi.nil?
    self.parent_component_name = compname
    self.dependencies = []
  end

  def get_component_definition(app)
    if self.parent_cart_name == app.name
      cart = app
    else
      cart = CartridgeCache::find_cartridge(self.parent_cart_name)
    end
    profile = cart.profiles(self.parent_cart_profile)
    group = profile.groups(self.parent_cart_group)
    comp_name = group.component_refs(self.parent_component_name).component
    comp = profile.components(comp_name)
    return comp,profile,cart
  end

  def elaborate(app)
    comp,profile,cart = get_component_definition(app)

    self.dependencies = []
    
    # cart map has all the sub-cartridges that will get instantiated through this component instance
    cart_map = get_cartridges_for_dependencies(comp, cart)

    group_list = cart_map.map { |name, cartprofile| 
      elaborate_cartridge(cartprofile[0], cartprofile[1], app) 
    }.flatten

    self.dependencies.each do |dep|
      cinst = app.comp_instance_map[dep]
      ComponentInstance.establish_connections(cinst, self, app)
    end

    return group_list
  end

  def self.establish_connections(inst1, inst2, app)
    comp1,prof1,cart1 = inst1.get_component_definition(app)
    comp2,prof2,cart2 = inst2.get_component_definition(app)
    
    comp1.publishes.each do |pub|
      comp2.subscribes.each do |sub|
        app.conn_endpoints_list << ConnectionEndpoint.new(inst1, inst2, pub, sub) if pub.type==sub.type
      end
    end
    comp1.subscribes.each do |sub|
      comp2.publishes.each do |pub|
        app.conn_endpoints_list << ConnectionEndpoint.new(inst2, inst1, pub, sub) if pub.type==sub.type
      end
    end
  end

  def elaborate_cartridge(cart, profile, app)
    profile.group_overrides.each do |n, v|
      from = self.name + "." + cart.name + "." + n
      to = self.name + "." + cart.name + "." + v
      app.group_override_map[from] = to
    end
    group_list = profile.groups.map do |g|
       gpath = self.name + "." + cart.name + "." + g.name
       mapped_path = app.group_override_map[gpath] || ""
       gi = app.group_instance_map[mapped_path]
       if gi.nil?
         gi = GroupInstance.new(cart.name, profile.name, g.name, gpath)
       else
         gi.merge(cart.name, profile.name, g.name, gpath)
       end
       app.group_instance_map[gpath] = gi
       app.working_group_inst_hash[gpath] = gi
       gi.elaborate(g, self.name, app)
       self.dependencies += gi.component_instances
       gi
    end

    # make connection_endpoints out of provided connections
    profile.connections.each do |conn|
      inst1 = find_component_in_cart(profile, app, conn.components[0], self.name)
      inst2 = find_component_in_cart(profile, app, conn.components[1], self.name)
      self.establish_connections(inst1, inst2, app)
    end
    
    return group_list
  end

  def self.find_component_in_cart(profile, app, comp_name, parent_path) 
    # assume comp_name is group_name.component_name for now
    # FIXME : it could be a component_name only, feature_name, cartridge_name that 
    #         one of the components depend upon, or a hierarchical name
    comp_inst = app.comp_instance_map[parent_path + "." + comp_name]
    if comp_inst.nil?
      parent_inst = app.comp_instance_map[parent_path]
      parent_inst.dependencies.each do |dep|
        dep_inst = app.comp_instance_map[dep]
      end
    end
    return comp_inst
  end

  def get_cartridges_for_dependencies(comp, cart)
    # resolve features into cartridges - two features may resolve
    # into one cartridge only, e.g. depends = [db,db-failover] 
    # will resolve into one mysql cartridge being instantiated with (master/slave) profile
    cart_map = {}
    depends = comp.depends + cart.requires_feature
    
    depends.each do |feature| 
      cart = CartridgeCache::find_cartridge(feature)
      raise Exception.new "Cannot find cartridge for dependency '#{feature}'" if cart.nil?
      capability = feature
      capability = nil if feature==cart.name
      profile = cart.find_profile(capability)
      cart_map[cart.name+profile.name] = [cart, profile]
    end
    return cart_map
  end

end
