module Cloud::Sdk
  class ComponentRef < Cloud::Sdk::UserModel
    attr_accessor :name, :component
    
    def initialize(name=nil)
      self.name = name
    end
    
    def from_descriptor(spec_hash)
      self.component = spec_hash
      self
    end
    
    def to_descriptor
      self.component
    end

    def get_name_prefix
      return "" if self.component.generated
      return "/comp-" + self.name 
    end
  end
end
