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
      
      env_echos = ["echo \"export PATH=#{cartridge_dir}/info/bin/:#{cartridge_root_dir}/abstract-httpd/info/bin/:#{cartridge_root_dir}/li-controller/info/bin/:/bin:/usr/bin\" > #{app_home}/.env/PATH"]

      env_echos.each do |env_echo|
        echo_output, echo_exitcode = Util.execute_script(env_echo)
        output += echo_output
      end
      
      if app_type == 'jbossas-7.0'
        jboss_home = '/etc/alternatives/jbossas-7.0'
        FileUtils.rm "#{app_dir}/jbossas-7.0/modules"
        FileUtils.ln_s "#{jboss_home}/modules/", "#{app_dir}/jbossas-7.0/modules"
        FileUtils.rm "#{app_dir}/jbossas-7.0/jboss-modules.jar"
        FileUtils.ln_s "#{jboss_home}/jboss-modules.jar", "#{app_dir}/jbossas-7.0/jboss-modules.jar"
      end
      
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
