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
      
      env_echos = []
      
      if app_type == 'jbossas-7.0'
        java_home = '/etc/alternatives/java_sdk_1.6.0'
        m2_home = '/etc/alternatives/maven-3.0'
        env_echos.push("echo \"export PATH=#{cartridge_dir}/info/bin/:#{cartridge_root_dir}/abstract-httpd/info/bin/:#{cartridge_root_dir}/abstract/info/bin/:#{java_home}/bin:#{m2_home}/bin:/bin:/usr/bin\" > #{app_home}/.env/PATH")
      elsif app_type == 'raw-0.1'
        env_echos.push("echo \"export PATH=#{cartridge_dir}/info/bin/:#{cartridge_root_dir}/abstract/info/bin/:/bin:/usr/bin\" > #{app_home}/.env/PATH")
      else
        env_echos.push("echo \"export PATH=#{cartridge_dir}/info/bin/:#{cartridge_root_dir}/abstract-httpd/info/bin/:#{cartridge_root_dir}/abstract/info/bin/:/bin:/usr/bin\" > #{app_home}/.env/PATH")
      end
      
      env_echos.each do |env_echo|
        echo_output, echo_exitcode = Util.execute_script(env_echo)
        output += echo_output
      end
      
      

      git_dir = "#{app_home}/git/#{app_name}.git/"
      FileUtils.chown(uuid, uuid, git_dir)
      FileUtils.chmod(0755, git_dir)
      
      gitconfig = "#{app_home}/.gitconfig"
      output += "Migrating .gitconfig: #{gitconfig}\n"
      file = File.open(gitconfig, 'w')
      begin
        file.puts <<EOF
[user]
  name = OpenShift System User
[gc]
  auto = 100
EOF
      ensure
        file.close
      end
      
      FileUtils.chown('root', 'root', gitconfig)
      FileUtils.chmod(0644, gitconfig)
      
      if app_type == 'php-5.3'
        output += Util.replace_in_file("#{app_dir}/conf/php.ini", 'upload_max_filesize = 10M', 'upload_max_filesize = 200M')
        output += Util.replace_in_file("#{app_dir}/conf/php.ini", 'post_max_size = 8M', 'post_max_size = 200M')
        output += Util.replace_in_file("#{app_dir}/conf/php.ini", 'max_execution_time = 30', 'max_execution_time = 300')
      end
      
      phpmyadmin_dir = "#{app_home}/phpmyadmin-3.4"
      if File.exists?(phpmyadmin_dir)
        output += Util.replace_in_file("#{phpmyadmin_dir}/conf/php.ini", 'upload_max_filesize = 2M', 'upload_max_filesize = 200M')
        output += Util.replace_in_file("#{phpmyadmin_dir}/conf/php.ini", 'post_max_size = 8M', 'post_max_size = 200M')
        output += Util.replace_in_file("#{phpmyadmin_dir}/conf/php.ini", 'max_execution_time = 30', 'max_execution_time = 300')
      end
      
      mysql_dir = "#{app_home}/mysql-5.1"
      if File.exists?(mysql_dir)
        output += Util.replace_in_file("#{mysql_dir}/etc/my.cnf", 'max_allowed_packet = 1M', 'max_allowed_packet = 200M')
      end
      
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
