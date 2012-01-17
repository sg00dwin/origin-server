module Cloud::Sdk
  class Component < Cloud::Sdk::UserModel
    attr_accessor :name, :publishes, :subscribes, :generated, :depends, :depends_service
    
    def initialize
      self.generated = false
    end
    
    def from_descriptor(spec_hash = {})
      self.name = spec_hash["Name"] || "default"
      self.publishes = {}
      if spec_hash["Publishes"]
        spec_hash["Publishes"].each do |n, p|
          conn = Connector.new(n).from_descriptor(p)
          self.publishes[conn.name]=conn
        end
      end
      
      self.subscribes = {}
      if spec_hash["Subscribes"]
        spec_hash["Subscribes"].each do |n,p|
          conn = Connector.new(n).from_descriptor(p)
          self.subscribes[conn.name]=conn
        end
      end
      
      self.depends = spec_hash["Dependencies"] || []
      self.depends_service = spec_hash["Service-Dependencies"] || []
      
      self
    end
    
    def to_descriptor
      p = {}
      self.publishes.each do |k,v|
        p[k] = v.to_descriptor
      end
      
      s = {}
      self.subscribes.each do |k,v|
        s[k] = v.to_descriptor
      end
      
      {
        "Publishes" => p,
        "Subscribes" => s,
        "Dependencies" => self.depends,
        "Service-Dependencies" => self.depends_service
      }
    end
  end
end