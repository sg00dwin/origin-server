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
      path = File.join(@gear_home, 'jbosseap', 'env', 'OPENSHIFT_JBOSSEAP_VERSION')
      if File.file? path
        progress.log ("Fixing OPENSHIFT_JBOSSEAP_VERSION environment variable for #{@uuid}")
        FileUtils.rm path
        IO.write(path, jboss_version)
      end

      # patch jenkins jobs config.xml for jbosseap-6.0 -> jbosseap-6 rename
      path = File.join(@gear_home, 'jenkins')
      if File.directory? path
        progress.log ("Patching jenkins builderType for #{@uuid}")
        file = "#{@gear_home}/app-root/data/jobs/*/config.xml"
        sep = ','
        old_value = 'jbosseap-6\.0'
        new_value = 'jbosseap-6'
        output = `sed -i "s#{sep}#{old_value}#{sep}#{new_value}#{sep}g" #{file} 2>&1`
        exitcode = $?.exitstatus
        progress.log ("Updated '#{file}' changed '#{old_value}' to '#{new_value}'.  output: #{output}  exitcode: #{exitcode}")
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
