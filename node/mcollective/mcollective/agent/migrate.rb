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
    if version == "2.0.14"
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

        gear_crondir = "#{gear_home}/cron-1.4"
        if File.exists?(gear_crondir)  &&  File.directory?(gear_crondir)
          output += "Recreating cron-1.4/jobs symlink for #{gear_name} ..."
          FileUtils.rm_f  "#{gear_crondir}/jobs"
          FileUtils.ln_sf "../app-root/repo/.openshift/cron",
                          "#{gear_crondir}/jobs"
          output += " done."
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
