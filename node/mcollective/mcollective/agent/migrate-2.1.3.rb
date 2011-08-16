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
      
      httpd_conf = "/etc/httpd/conf.d/libra/#{uuid}_#{namespace}_#{app_name}.conf"
      grep_output, grep_exitcode = Util.execute_script("grep 'ProxyPass / http://' #{httpd_conf} 2>&1")
      ip = grep_output[grep_output.index('http://') + 'http://'.length..-1]
      ip = ip[0..ip.index(':')-1]

      FileUtils.mkdir_p "#{app_home}/.env/"
      
      env_echos = ["echo \"export OPENSHIFT_APP_NAME='#{app_name}'\" > #{app_home}/.env/OPENSHIFT_APP_NAME",
              "echo \"export PATH=/bin:/usr/bin:#{cartridge_dir}/info/bin/:#{cartridge_root_dir}/abstract-httpd/info/bin/:#{cartridge_root_dir}/li-controller/info/bin/\" > #{app_home}/.env/PATH",
              "echo \"export OPENSHIFT_APP_DIR='#{app_dir}/'\" > #{app_home}/.env/OPENSHIFT_APP_DIR",
              "echo \"export OPENSHIFT_REPO_DIR='#{app_dir}/repo/'\" > #{app_home}/.env/OPENSHIFT_REPO_DIR",
              "echo \"export OPENSHIFT_INTERNAL_IP='#{ip}'\" > #{app_home}/.env/OPENSHIFT_INTERNAL_IP",
              "echo \"export OPENSHIFT_INTERNAL_PORT='8080'\" > #{app_home}/.env/OPENSHIFT_INTERNAL_PORT",
              "echo \"export OPENSHIFT_LOG_DIR='#{app_dir}/logs/'\" > #{app_home}/.env/OPENSHIFT_LOG_DIR",
              "echo \"export OPENSHIFT_DATA_DIR='#{app_dir}/data/'\" > #{app_home}/.env/OPENSHIFT_DATA_DIR",
              "echo \"export OPENSHIFT_TMP_DIR='/tmp/'\" > #{app_home}/.env/OPENSHIFT_TMP_DIR",
              "echo \"export OPENSHIFT_RUN_DIR='#{app_dir}/run/'\" > #{app_home}/.env/OPENSHIFT_RUN_DIR",
              "echo \"export OPENSHIFT_APP_CTL_SCRIPT='#{app_dir}/#{app_name}_ctl.sh'\" > #{app_home}/.env/OPENSHIFT_APP_CTL_SCRIPT",
              "echo \"export OPENSHIFT_APP_DNS='#{app_name}-#{namespace}.#{libra_domain}'\" > #{app_home}/.env/OPENSHIFT_APP_DNS",
              "echo \"export OPENSHIFT_APP_UUID='#{uuid}'\" > #{app_home}/.env/OPENSHIFT_APP_UUID",
              "echo \"export OPENSHIFT_HOMEDIR='#{app_home}/'\" > #{app_home}/.env/OPENSHIFT_HOMEDIR"
              ]
              
      env_echos.each do |env_echo|
        echo_output, echo_exitcode = Util.execute_script(env_echo)
        output += echo_output
      end
      
      if File.exists?("#{app_home}/.env/OPENSHIFT_DB_USERNAME")
        FileUtils.chown(uuid, "root", "#{app_home}/.env/OPENSHIFT_DB_USERNAME")
        FileUtils.chown(uuid, "root", "#{app_home}/.env/OPENSHIFT_DB_PASSWORD")
      end
      
      post_receive = "#{app_home}/git/#{app_name}.git/hooks/post-receive"
      output += "Migrating post-receive: #{post_receive}\n"
      file = File.open(post_receive, 'w')
      begin
        file.puts <<EOF
#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

post_receive_app.sh #{libra_server}
EOF

      ensure
        file.close
      end
      
      pre_receive = "#{app_home}/git/#{app_name}.git/hooks/pre-receive"
      output += "Migrating pre-receive: #{pre_receive}\n"
      file = File.open(pre_receive, 'w')
      begin
        file.puts <<EOF
#!/bin/bash

# Import Environment Variables
for f in ~/.env/*
do
    . $f
done

pre_receive_app.sh
EOF
    
      ensure
        file.close
      end
      
      
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
