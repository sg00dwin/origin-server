require 'rubygems'
require 'fileutils'
require 'socket'
require 'parseconfig'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"

module LibraMigration

  def self.get_config_value(key)
    @node_config ||= ParseConfig.new('/etc/stickshift/stickshift-node.conf')
    val = @node_config.get_value(key)
    val.gsub!(/\\:/,":") if not val.nil?
    val.gsub!(/[ \t]*#[^\n]*/,"") if not val.nil?
    val = val[1..-2] if not val.nil? and val.start_with? "\""
    val
  end

  def self.convert_haproxy_registry_line(ginfo)
    gbits = ginfo.split(";")
    return ginfo if gbits.length > 1

    # Need to do a conversion.
    uuid = gbits[0].split("@")[0]
    gdns = gbits[0].split("@")[1].split(":")[0]
    gdir = gbits[0].split("@")[1].split(":")[1]
    ipaddr = gdns
    begin
      ipaddr = IPSocket.getaddress(gdns)
    rescue
    end
    "#{uuid}@#{ipaddr}:#{gdir};#{gdns}"
  end

  def self.migrate_haproxy_configuration(uuid, gear_home)
    registry_db = "#{gear_home}/haproxy-1.4/conf/gear-registry.db"
    Util.execute_script("chown #{uuid} #{registry_db}")
    cfgdata = ""
    regdata = File.readlines(registry_db)
    regdata.map! { |data| data.gsub(/\r\n?/, "\n") }
    regdata.each do |line|
      cfgdata += convert_haproxy_registry_line(line.delete("\n")) + "\n"
    end
    File.open(registry_db, "w") { |file| file.puts cfgdata }
  end

  def self.migrate(uuid, namespace, version)

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

      env_echos = []

      if File.exists?("#{gear_home}/haproxy-1.4/conf/gear-registry.db")
        migrate_haproxy_configuration(uuid, gear_home)
      end

      env_echos.each do |env_echo|
        echo_output, echo_exitcode = Util.execute_script(env_echo)
        output += echo_output
      end

    else
      exitcode = 127
      output += "Application not found to migrate: #{gear_home}\n"
    end
    return output, exitcode
  end
end
