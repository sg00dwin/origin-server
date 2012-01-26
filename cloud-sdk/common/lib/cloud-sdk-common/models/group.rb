module Cloud::Sdk
  class Group < Cloud::Sdk::UserModel
    attr_accessor :name, :component_refs, :component_refs, :scaling, :generated
    
    def initialize(name="default")
      self.name = name
      self.component_refs = {}
      self.component_refs = {}
      self.scaling = Scaling.new
      self.generated = false
    end
    
    def component_refs=(hash)
      component_refs_will_change!
      @component_refs = {}
      hash.each do |key, value|
        if value.class == Hash
          @component_refs[key] = ComponentRef.new(key)
          @component_refs[key].attributes=value
        else
          @component_refs[key] = value
        end
      end
    end
    
    def component_refs=(hash)
      component_refs_will_change!
      @component_refs = {}
      hash.each do |key, value|
        if value.class == Hash
          @component_refs[key] = ComponentRef.new(key)
          @component_refs[key].attributes=value
        else
          @component_refs[key] = value
        end
      end
    end
    
    def scaling=(value)
      scaling_will_change!
      if value.class == Hash
        @scaling = Scaling.new
        @scaling.attributes=value
      else
        @scaling = value
      end
    end
    
    def from_descriptor(spec_hash = {})
      self.name = spec_hash["Name"] || "default"
      self.component_refs = {}
      if spec_hash.has_key?("Components")
        spec_hash["Components"].each do |n,c|
          self.component_refs[n]=ComponentRef.new(n).from_descriptor(c)
        end
      end
      self.scaling.from_descriptor spec_hash["Scaling"] if spec_hash.has_key?("Scaling")
      self
    end
    
    def to_descriptor
      components = {}
      self.component_refs.each do |n,c|
        components[n] = c.to_descriptor
      end

      {
        "Components" => components,
        "Scaling" => self.scaling.to_descriptor
      }
    end
  end
end