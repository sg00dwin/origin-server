require 'rubygems'
require 'etc'
require 'fileutils'
require 'socket'
require 'parseconfig'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"

module OpenShiftMigration

  def self.get_config_value(key)
    @node_config ||= ParseConfig.new('/etc/stickshift/stickshift-node.conf')
    val = @node_config.get_value(key)
    val.gsub!(/\\:/,":") if not val.nil?
    val.gsub!(/[ \t]*#[^\n]*/,"") if not val.nil?
    val = val[1..-2] if not val.nil? and val.start_with? "\""
    val
  end

  # Note: This method must be reentrant.  Meaning it should be able to 
  # be called multiple times on the same gears.  Each time having failed 
  # at any point and continue to pick up where it left off or make
  # harmless changes the 2-n times around.
  def self.migrate(uuid, namespace, version)
    if version == "2.0.15"
      libra_home = '/var/lib/stickshift' #node_config.get_value('libra_dir')
      libra_server = get_config_value('BROKER_HOST')
      libra_domain = get_config_value('CLOUD_DOMAIN')
      gear_home = "#{libra_home}/#{uuid}"
      gear_name = Util.get_env_var_value(gear_home, "OPENSHIFT_GEAR_NAME")
      gear_dir = "#{gear_home}/#{gear_name}"
      output = ''
      exitcode = 0

      if (File.exists?(gear_home) && !File.symlink?(gear_home))
        gear_type = Util.get_env_var_value(gear_home, "OPENSHIFT_GEAR_TYPE")
        cartridge_root_dir = "/usr/libexec/stickshift/cartridges"
        cartridge_dir = "#{cartridge_root_dir}/#{gear_type}"

        # BZ 842977: Inhibit stale detection for mysql and mongodb gears
        if ['mysql-5.1','mongodb-2.0'].include? gear_type
          File.open("#{gear_home}/.disable_stale","w") {}
        end
        
        # BZ 844267: switch /jbossas-7/jbossas-7/standalone/deployments from a copy to a link to app-root/repo/deployments
        if ['jbossas-7'].include? gear_type
          FileUtils.rm_rf("#{gear_home}/jbossas-7/jbossas-7/standalone/deployments")
          File.symlink("#{gear_home}/app-root/repo/deployments","#{gear_home}/jbossas-7/jbossas-7/standalone/deployments")
        end
        if ['jbosseap-6.0'].include? gear_type
          FileUtils.rm_rf("#{gear_home}/jbosseap-6.0/jbosseap-6.0/standalone/deployments")
          File.symlink("#{gear_home}/app-root/repo/deployments","#{gear_home}/jbosseap-6.0/jbosseap-6.0/standalone/deployments")
        end

        env_echos = []

        env_echos.each do |env_echo|
          echo_output, echo_exitcode = Util.execute_script(env_echo)
          output += echo_output
        end

      else
        exitcode = 127
        output += "Application not found to migrate: #{gear_home}\n"
      end
      return output, exitcode
    else
      return "Invalid version: #{version}", 255
    end
  end
end
