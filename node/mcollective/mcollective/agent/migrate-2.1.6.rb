require 'rubygems'
require 'fileutils'
require 'parseconfig'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"

module LibraMigration

  def self.migrate(uuid, app_name, app_type, namespace, version)
    node_config = ParseConfig.new('/etc/libra/node.conf')
    libra_home = '/var/lib/libra' #node_config.get_value('libra_dir')
    libra_server = node_config.get_value('libra_server')
    libra_domain = node_config.get_value('libra_domain')
    app_home = "#{libra_home}/#{uuid}"
    app_dir = "#{app_home}/#{app_name}"
    output = ''
    exitcode = 0
    if (File.exists?(app_home) && !File.symlink?(app_home))
      
      cartridge_root_dir = "/usr/libexec/li/cartridges"
      cartridge_dir = "#{cartridge_root_dir}/#{app_type}"
      
      if app_type == 'jbossas-7.0'
        FileUtils.rm "#{app_dir}/jbossas-7.0/bin/standalone.sh"
        FileUtils.ln_s "#{cartridge_dir}/info/bin/standalone.sh", "#{app_dir}/jbossas-7.0/bin/standalone.sh"
          
        FileUtils.rm "#{app_dir}/jbossas-7.0/bin/standalone.conf"
        FileUtils.ln_s "#{cartridge_dir}/info/bin/standalone.conf", "#{app_dir}/jbossas-7.0/bin/standalone.conf"
      end
      
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
