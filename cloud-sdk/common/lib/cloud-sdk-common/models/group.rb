module Cloud::Sdk
  class Group < Cloud::Sdk::UserModel
    attr_accessor :name, :component_refs, :auto_component_refs, :scaling, :generated
    
    def initialize
      self.name = "default"
      self.component_refs = {}
      self.auto_component_refs = {}
      self.scaling = Scaling.new
      self.generated = false
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