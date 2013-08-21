module OpenShift
  class GearUpgradeExtension

    VERSION_MAP = {
      'phpmyadmin-3.4'      => '3',
      'jbosseap-6.0'        => '6',
      'jenkins-1.4'         => '1',
      'jenkins-client-1.4'  => '1',
      'switchyard-0.6'      => '0',
    }

    def self.version
      '2.0.32'
    end

    def initialize(upgrader)
      @upgrader = upgrader
      @uuid = upgrader.uuid
      @gear_home = upgrader.gear_home
      @container = upgrader.container
    end

    def pre_upgrade(progress)
      path = File.join(@gear_home, '.env', 'user_vars')
      FileUtils.mkpath(path)
      FileUtils.chmod(0770, path)
      @upgrader.container.set_ro_permission(path)
      progress.log("Created #{path}")

      progress.log "Set gear OPENSHIFT_APP_UUID to #{@upgrader.application_uuid}"
      @upgrader.container.add_env_var("APP_UUID", @upgrader.application_uuid, true)
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
