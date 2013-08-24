module OpenShift
  class GearUpgradeExtension

    VERSION_MAP = {
      'phpmyadmin-3' => '4'
    }

    def self.version
      '2.0.33'
    end

    def initialize(uuid, gear_home, container)
      @uuid      = uuid
      @gear_home = gear_home
      @container = container
    end

    def pre_upgrade(progress)
    end

    def map_ident(progress, ident)
      vendor, name, version, cartridge_version = OpenShift::Runtime::Manifest.parse_ident(ident)
      progress.log "In map_ident"
      name_version = "#{name}-#{version}"
      progress.log "Mapping version #{version} to #{VERSION_MAP[name_version]} for cartridge #{name}" if VERSION_MAP[name_version]
      version = VERSION_MAP[name_version] || version
      return vendor, name, version, cartridge_version
    end
  end
end
