module Cloud::Sdk
  class Profile < Cloud::Sdk::UserModel
    validates_presence_of :name, :groups
    attr_accessor :name, :provides, :components, :groups, :group_overrides,
                  :connections, :property_overrides, :service_overrides,
                  :start_order, :stop_order, :configure_order, :generated
    
    def initialize
      self.generated = false
      self.provides = []
    end
    
    def components=(hash)
      components_will_change!
      @components = {}
      hash.each do |key, value|
        if value.class == Hash
          @components[key] = Component.new(key)
          @components[key].attributes=value
        else
          @components[key] = value
        end
      end
    end
    
    def groups=(hash)
      groups_will_change!
      @groups = {}
      hash.each do |key, value|
        if value.class == Hash
          @groups[key] = Group.new(key)
          @groups[key].attributes=value
        else
          @groups[key] = value
        end
      end
    end
    
    def connections=(hash)
      connections_will_change!
      @connections = {}
      hash.each do |key, value|
        if value.class == Hash
          @connections[key] = Connection.new(key)
          @connections[key].attributes=value
        else
          @connections[key] = value
        end
      end
    end

    def from_descriptor(spec_hash = {})
      self.name = spec_hash["Name"] || "default"
      self.provides = spec_hash["Provides"] || []
      self.start_order = spec_hash["Start-Order"] || []
      self.stop_order = spec_hash["Stop-Order"] || []
      self.configure_order = spec_hash["Configure-Order"] || []
      
      #fixup user data. provides, start_order, start_order, configure_order bust be arrays
      self.provides = [self.provides] if self.provides.class == String
      self.start_order = [self.start_order] if self.start_order.class == String
      self.stop_order = [self.stop_order] if self.stop_order.class == String
      self.configure_order = [self.configure_order] if self.configure_order.class == String
      
      self.components = {}
      if spec_hash.has_key?("Components")
        spec_hash["Components"].each do |cname, c|
         comp = Component.new.from_descriptor(c)
         comp.name = cname
         self.components[comp.name] = comp
       end
      else
        comp_spec_hash = spec_hash.dup.delete_if{|k,v| !["Publishes", "Subscribes"].include?(k) }
        c = Component.new.from_descriptor(comp_spec_hash)
        c.generated = true
        self.components = {"default" => c}
      end
      
      self.groups = {}
      if spec_hash.has_key?("Groups")
        spec_hash["Groups"].each do |gname, g|
          group = Group.new.from_descriptor(g)
          group.name = gname
          self.groups[group.name] = group
        end
      else
        group = Group.new
        self.components.keys.each do |c|
          group.component_refs[c]=ComponentRef.new(c).from_descriptor(c)
        end
        group.generated = true
        self.groups = {"default" => group}
      end
      
      self.connections = {}
      if spec_hash.has_key?("Connections")
        spec_hash["Connections"].each do |n,c|
          conn = Connection.new(n).from_descriptor(c)
          self.connections[conn.name] = conn
        end
      end

      self.group_overrides = {}
      if spec_hash.has_key?("GroupOverrides")
        spec_hash["GroupOverrides"].each do |go|
          # each group override is a list
          map_to = go.pop
          go.each { |g| group_overrides[g] = map_to }
        end
      end
      self
    end
    
    def to_descriptor
      h = {}
      h["Provides"] = @provides unless @provides.nil? || @provides.empty?
      h["Start-Order"] = @start_order unless @start_order.nil? || @start_order.empty?
      h["Stop-Order"] = @stop_order unless @stop_order.nil? || @stop_order.empty?
      h["Configure-Order"] = @configure_order unless @configure_order.nil? || @configure_order.empty?
  
      if @components.keys.length == 1 && @components.values.first.generated
        comp_h = @components.values.first.to_descriptor
        comp_h.delete("Name")
        h.merge!(comp_h)
      else
        h["Components"] = {}
        @components.each do |k,v|
          h["Components"][k] = v.to_descriptor
        end
      end
      
      unless @groups.keys.length == 1 && @groups.values.first.generated
        h["Groups"] = {}
        @groups.each do |k,v|
          h["Groups"][k] = v.to_descriptor
        end
      end
      h["Connections"] = {}
      @connections.each do |n,v|
        h["Connections"][n] = v.to_descriptor
      end
      h
    end
  end
end
