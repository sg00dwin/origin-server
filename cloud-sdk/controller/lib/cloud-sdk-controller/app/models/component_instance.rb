class ComponentInstance < Cloud::Sdk::UserModel
  attr_accessor :state, :parent_cart_name, :parent_cart_profile, :parent_component_name,
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

  def initialize (cartname, profname, compname, pathname, gi)
    self.name = pathname
    self.parent_cart_name = cartname
    self.parent_cart_profile = profname
    self.group_instance_name = gi.name
    self.parent_component_name = compname
    self.dependencies = []
  end

  def get_component_definition
    if self.parent_cart_name == app.name
      cart = app
    else
      cart = CartridgeCache::find_cartridge(self.parent_cart_name)[0]
    end
    profile = cart.profiles[self.parent_cart_profile]
    comp = profile.components[self.parent_component_name]
    return comp
  end

  def elaborate(app)
    # get this instance's actual component from cartridge's descriptor
    if self.parent_cart_name == app.name
      cart = app
    else
      cart = CartridgeCache::find_cartridge(self.parent_cart_name)[0]
    end
    profile = cart.profiles[self.parent_cart_profile]
    comp = profile.components[self.parent_component_name]
 
    # cart map has all the sub-cartridges that will get instantiated through this component instance
    cart_map = get_cartridges_for_dependencies(comp)

    group_list = cart_map.map { |name, cartprofile| 
      elaborate_cartridge(cartprofile[0], cartprofile[1], app) 
    }.flatten

    self.dependencies.each do |dep|
      cinst = app.comp_instance_map[dep]
      establish_connections(cinst, self, app)
    end

    return group_list
  end

  def self.establish_connections(inst1, inst2, app)
    comp1 = inst1.get_component_definition
    comp2 = inst2.get_component_definition
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
    group_list = profile.groups.map do |k,g|
       gpath = self.path + "." + cart.name + ":" + profile.name + "." + k
       gi = GroupInstance.new(cart.name, profile.name, gpath)
       app.group_instance_map[gpath] = gi
       gi.elaborate(g, self.path, app)
       self.dependencies << gi.component_instances
       gi
    end

    # make connection_endpoints out of provided connections
    profile.connections.each do |name, conn|
      inst1 = find_component_in_cart(profile, app, conn.components[0], self.name)
      inst2 = find_component_in_cart(profile, app, conn.components[1])
      self.establish_connections(inst1, inst2, app)
    end
    
    return group_list
  end

  def self.find_component_in_cart(profile, app, comp_name, parent_path) 
    # assume comp_name is group_name.component_name for now
    # FIXME : it could be a component_name only, feature_name, cartridge_name that 
    #         one of the components depend upon, or a hierarchical name
    return app.comp_instance_map[parent_path + "." + comp_name]
  end

  def get_cartridges_for_dependencies(comp)
    # resolve features into cartridges - two features may resolve
    # into one cartridge only, e.g. depends = [db,db-failover] 
    # will resolve into one mysql cartridge being instantiated with (master/slave) profile
    cart_map = {}
    comp.depends.each do |feature| 
      cart = CartridgeCache::find_cartridge(feature)
      raise Exception "Cannot find cartridge for dependency '#{feature}'" if cart.nil?
      capability = feature
      capability = nil if feature==cart.name
      profile = cart.find_profile(capability)
      cart_map[cart.name+profile.name] = [cart, profile]
    end
    return cart_map
  end

end
