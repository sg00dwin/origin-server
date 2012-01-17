module Cloud::Sdk
  class Cartridge < Cloud::Sdk::UserModel
    attr_accessor :name, :version, :architecture, :display_name, :description, :vendor, :license,
                  :provides_feature, :requires_feature, :conflicts_feature, :requires, :default_profile,
                  :profiles, :path
    
    def initialize
      super
      self.from_descriptor({"Name" => "unknown-cartridge"})
    end
    
    def all_capabilities
      caps = self.provides_feature.dup
      self.profiles.each do |k,v|
        caps += v.provides
      end
      caps.uniq
    end
    
    # Search for a profile that provides specified capabilities
    def find_profile(capability)
      if capability.nil? || self.provides_feature.include?(capability)
        return self.profiles[self.default_profile] 
      end
      
      self.profiles.values.each do |p|
        return p if p.provides.include? capability
      end
      nil
    end
                  
    def from_descriptor(spec_hash={})
      self.name = spec_hash["Name"]
      self.version = spec_hash["Version"] || "0.0"
      self.architecture = spec_hash["Architecture"] || "noarch"
      self.display_name = spec_hash["Display-Name"] || "#{self.name}-#{self.version}-#{self.architecture}"
      self.license = spec_hash["License"] || "unknown"
      self.vendor = spec_hash["Vendor"] || "unknown"
      self.description = spec_hash["Description"] || ""
      self.provides_feature = spec_hash["Provides"] || []
      self.requires_feature = spec_hash["Requires"] || []
      self.conflicts_feature = spec_hash["Conflicts"] || []
      self.requires = spec_hash["Native-Requires"] || []
      
      self.provides_feature = [self.provides_feature] if self.provides_feature.class == String
      self.requires_feature = [self.requires_feature] if self.requires_feature.class == String
      self.conflicts_feature = [self.conflicts_feature] if self.conflicts_feature.class == String
      self.requires = [self.requires] if self.requires.class == String
      
      self.profiles = {}
      if spec_hash.has_key?("Profiles")
        spec_hash["Profiles"].each do |pname, p|
          profile = Profile.new.from_descriptor(p)
          profile.name = pname
          self.profiles[pname] = profile
        end
      else
        ["Name", "Version", "Architecture", "DisplayName", "License",
           "Provides", "Requires", "Conflicts", "Native-Requires"].each do |k|
          spec_hash.delete(k)
        end
        p = Profile.new.from_descriptor(spec_hash)
        p.generated = true
        self.profiles = {"default" => p}
      end
      self.default_profile = spec_hash["Default-Profile"] || self.profiles.values.first.name
      self
    end
    
    def to_descriptor
      h = {
        "Name" => self.name,
        "Version" => self.version,
        "Architecture" => self.architecture,
        "Display-Name" => self.display_name,
        "License" => self.license,
        "Provides" => self.provides_feature,
        "Requires" => self.requires_feature,
        "Conflicts" => self.conflicts_feature,
        "Native-Requires" => self.requires,
        "Default-Profile" => self.default_profile,
        "Description" => self.description,
        "Vendor" => self.vendor
      }
      
      if self.profiles.values.length == 1 && self.profiles.values.first.generated
        profile_h = self.profiles.values.first.to_descriptor
        profile_h.delete("Name")
        h.merge!(profile_h)
      else
        h["Profiles"] = {}
        self.profiles.each do |n,v|
          h["Profiles"][n] = v.to_descriptor
        end
      end
      
      h
    end
  end
end