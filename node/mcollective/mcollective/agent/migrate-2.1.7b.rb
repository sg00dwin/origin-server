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

      env_echos = []
      
      mysql_dir = "#{app_home}/mysql-5.1"
      if File.exists?(mysql_dir)
        
        my_cnf = "#{mysql_dir}/etc/my.cnf"
        grep_output, grep_exitcode = Util.execute_script("grep '^bind-address=' #{my_cnf} 2>&1")
        ip = grep_output['bind-address='.length..-1]
        ip.chomp!
        
        output += "Using ip='#{ip}'"
        
        env_echos.push("echo \"export OPENSHIFT_DB_HOST='#{ip}'\" > #{app_home}/.env/OPENSHIFT_DB_HOST")
        
        password = Util.get_env_var_value(app_home, "OPENSHIFT_DB_PASSWORD")
        
        if password == 'NOT_AVAILABLE'
          env_echos.push("echo \"export OPENSHIFT_DB_URL='mysql://admin@#{ip}:3306/'\" > #{app_home}/.env/OPENSHIFT_DB_URL")
        end
      end
      
      env_echos.each do |env_echo|
        echo_output, echo_exitcode = Util.execute_script(env_echo)
        output += echo_output
      end
      
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
