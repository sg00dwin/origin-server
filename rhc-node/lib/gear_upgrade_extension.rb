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

    def initialize(uuid, gear_home, container)
      @uuid      = uuid
      @gear_home = gear_home
      @container = container
    end

    def pre_upgrade(progress)
      path = File.join(@gear_home, '.env', 'user_vars')
      FileUtils.mkpath(path)
      FileUtils.chmod(0770, path)
      @container.set_ro_permission(path)
      progress.log("Created #{path}")

      # Repair @gear_home/jbosseap/ symlinks to /etc/alternatives/ links
      jboss_version = '6'
      jboss_home = "/etc/alternatives/jbosseap-#{jboss_version}"
      path = File.join(@gear_home, 'jbosseap')
      if File.directory? path
        progress.log ("Fixing jbosseap/jboss-modules.jar symlink for #{@uuid}")
        FileUtils.ln_sf(File.join(jboss_home, 'jboss-modules.jar'), File.join(path, 'jboss-modules.jar'))
        progress.log ("Fixing jbosseap/modules symlink for #{@uuid}")
        FileUtils.ln_sf(File.join(jboss_home, 'modules'), File.join(path, 'modules'))
      end

      # Repair OPENSHIFT_JBOSSEAP_VERSION env var
      progress.log ("Fixing OPENSHIFT_JBOSSEAP_VERSION environment variable for #{@uuid}")
      path = File.join(@gear_home, 'jbosseap', 'env', 'OPENSHIFT_JBOSSEAP_VERSION')
      if File.file? path
        FileUtils.rm path
        IO.write(path, jboss_version)
      end
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
