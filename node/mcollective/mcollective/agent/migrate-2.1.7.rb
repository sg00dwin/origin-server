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
      
      env_echos = ["echo \"export OPENSHIFT_APP_DNS='#{app_name}-#{namespace}.#{libra_domain}'\" > #{app_home}/.env/OPENSHIFT_APP_DNS"]
        
      if app_type == 'jbossas-7.0'
        java_home = '/etc/alternatives/java_sdk_1.6.0'
        m2_home = '/etc/alternatives/maven-3.0'
        env_echos.push("echo \"export JAVA_HOME=#{java_home}\" > #{app_home}/.env/JAVA_HOME")
        env_echos.push("echo \"export M2_HOME=#{m2_home}\" > #{app_home}/.env/M2_HOME")
        env_echos.push("echo \"export PATH=#{cartridge_dir}/info/bin/:#{cartridge_root_dir}/abstract-httpd/info/bin/:#{cartridge_root_dir}/abstract/info/bin/:#{cartridge_root_dir}/li-controller/info/bin/:#{java_home}/bin:#{m2_home}/bin:/bin:/usr/bin\" > #{app_home}/.env/PATH")
      elsif app_type == 'raw-0.1'
        # no need to migrate yet
      else
        env_echos.push("echo \"export PATH=#{cartridge_dir}/info/bin/:#{cartridge_root_dir}/abstract-httpd/info/bin/:#{cartridge_root_dir}/abstract/info/bin/:#{cartridge_root_dir}/li-controller/info/bin/:/bin:/usr/bin\" > #{app_home}/.env/PATH")
      end
      
      mysql_dir = "#{app_home}/mysql-5.1"
      if File.exists?(mysql_dir)
        ip = Util.get_env_var_value(app_home, "OPENSHIFT_INTERNAL_IP")
        mysql_cart_bin_dir = "#{cartridge_root_dir}/embedded/mysql-5.1/info/bin"
        env_echos.push("echo \"export OPENSHIFT_DB_USERNAME='admin'\" > #{app_home}/.env/OPENSHIFT_DB_USERNAME")
        env_echos.push("echo \"export OPENSHIFT_DB_TYPE='mysql'\" > #{app_home}/.env/OPENSHIFT_DB_TYPE")
        env_echos.push("echo \"export OPENSHIFT_DB_HOST='#{ip}'\" > #{app_home}/.env/OPENSHIFT_DB_HOST")
        env_echos.push("echo \"export OPENSHIFT_DB_PORT='3306'\" > #{app_home}/.env/OPENSHIFT_DB_PORT")
        env_echos.push("echo \"export OPENSHIFT_DB_SOCKET='#{mysql_dir}/socket/mysql.sock'\" > #{app_home}/.env/OPENSHIFT_DB_SOCKET")
        env_echos.push("echo \"export OPENSHIFT_DB_CTL_SCRIPT='#{mysql_dir}/#{app_name}_mysql_ctl.sh'\" > #{app_home}/.env/OPENSHIFT_DB_CTL_SCRIPT")
        env_echos.push("echo \"export OPENSHIFT_DB_MYSQL_51_DUMP='#{mysql_cart_bin_dir}/mysql_dump.sh'\" > #{app_home}/.env/OPENSHIFT_DB_MYSQL_51_DUMP")
        env_echos.push("echo \"export OPENSHIFT_DB_MYSQL_51_DUMP_CLEANUP='#{mysql_cart_bin_dir}/mysql_cleanup.sh'\" > #{app_home}/.env/OPENSHIFT_DB_MYSQL_51_DUMP_CLEANUP")
        env_echos.push("echo \"export OPENSHIFT_DB_MYSQL_51_RESTORE='#{mysql_cart_bin_dir}/mysql_restore.sh'\" > #{app_home}/.env/OPENSHIFT_DB_MYSQL_51_RESTORE")
        env_echos.push("echo \"export OPENSHIFT_DB_MYSQL_51_EMBEDDED_TYPE='mysql-5.1'\" > #{app_home}/.env/OPENSHIFT_DB_MYSQL_51_EMBEDDED_TYPE")

        if !File.exists?("#{app_home}/.env/OPENSHIFT_DB_URL")
          env_echos.push("echo \"export OPENSHIFT_DB_URL='mysql://admin@#{ip}:3306/'\" > #{app_home}/.env/OPENSHIFT_DB_URL")
        end
        if !File.exists?("#{app_home}/.env/OPENSHIFT_DB_PASSWORD")
          env_echos.push("echo \"export OPENSHIFT_DB_PASSWORD='NOT_AVAILABLE'\" > #{app_home}/.env/OPENSHIFT_DB_PASSWORD")
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
