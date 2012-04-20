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
        ipaddr = IPSocket.getaddress(Socket.gethostname)
        registry_db = "#{gear_home}/haproxy-1.4/conf/gear-registry.db"
        Util.execute_script("chown #{uuid} #{registry_db}")
        #  Be careful of the slashes here, replace_in_file generates and runs a
        #  sed command, so need an extra set to escape 'em slashes.
        Util.replace_in_file(registry_db, "\\\(.*\\\)\\@\\\(.*\\\):\\\(.*\\\)",
                             "\\1@#{ipaddr}:\\3;\\2")
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
