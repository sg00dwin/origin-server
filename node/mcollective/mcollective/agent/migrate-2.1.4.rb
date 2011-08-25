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
      
      FileUtils.chmod(0750, "#{app_home}/.env")
      FileUtils.chown_R("root", uuid, "#{app_home}/.env")
      
      #uid=`id -u "#{uuid}"`
      #c_val=`echo c$((#{uid}/1023)),c$((#{uid}%1023))`.chomp
      
      ctl_sh = "#{app_home}/#{app_name}/#{app_name}_ctl.sh"
      output += "Migrating _ctl.sh: #{ctl_sh}\n"
      file = File.open(ctl_sh, 'w')
      begin
file.puts <<EOF
#!/bin/bash -e
# Import Environment Variables
for f in ~/.env/*
do
    . $f
done
app_ctl.sh $1
EOF

      ensure
        file.close
      end
      
      mysql_ctl_sh = "#{app_home}/mysql-5.1/#{app_name}_mysql_ctl.sh"
      if File.exists?(mysql_ctl_sh)
        output += "Migrating mysql_ctl_sh: #{mysql_ctl_sh}\n"
        FileUtils.rm_rf mysql_ctl_sh
        FileUtils.ln_s "#{cartridge_root_dir}/embedded/mysql-5.1/info/bin/mysql_ctl.sh", mysql_ctl_sh
      end
      
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
