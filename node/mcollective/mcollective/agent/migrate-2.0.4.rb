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
      if app_type == 'rack-1.1' || app_type == 'ruby-1.8' 
        env_echos.push("echo \"export OPENSHIFT_APP_TYPE='ruby-1.8'\" > #{app_home}/.env/OPENSHIFT_APP_TYPE")
        env_echos.push("echo \"export PATH=#{cartridge_root_dir}/ruby-1.8/info/bin/:#{cartridge_root_dir}/abstract-httpd/info/bin/:#{cartridge_root_dir}/abstract/info/bin/:/bin:/usr/bin\" > #{app_home}/.env/PATH")
      elsif app_type == 'wsgi-3.2' || app_type == 'python-2.6'
        env_echos.push("echo \"export OPENSHIFT_APP_TYPE='python-2.6'\" > #{app_home}/.env/OPENSHIFT_APP_TYPE")
        env_echos.push("echo \"export PATH=#{cartridge_root_dir}/python-2.6/info/bin/:#{cartridge_root_dir}/abstract-httpd/info/bin/:#{cartridge_root_dir}/abstract/info/bin/:/bin:/usr/bin\" > #{app_home}/.env/PATH")
      elsif app_type == 'php-5.3' || app_type == 'perl-5.10' || app_type == 'jenkins-1.4'
        # Unrelated to renames, this fixes a double cartridge_dir/info/bin listing
        env_echos.push("echo \"export PATH=#{cartridge_dir}/info/bin/:#{cartridge_root_dir}/abstract-httpd/info/bin/:#{cartridge_root_dir}/abstract/info/bin/:/bin:/usr/bin\" > #{app_home}/.env/PATH")
      end
      
      env_echos.each do |env_echo|
        echo_output, echo_exitcode = Util.execute_script(env_echo)
        output += echo_output
      end
      
      sed_output, sed_exitcode = Util.execute_script("sed -i 's/,no-port-forwarding//' #{app_home}/.ssh/authorized_keys")
      output += sed_output
      
      ip = Util.get_env_var_value(app_home, "OPENSHIFT_INTERNAL_IP")
      
      if app_type == 'rack-1.1' || app_type == 'ruby-1.8'
        deploy_httpd_config = "#{cartridge_dir}/info/bin/deploy_httpd_config.sh"
        if File.exists?(deploy_httpd_config)
          deploy_httpd_config_output, deploy_httpd_config_exitcode = Util.execute_script("#{deploy_httpd_config} #{app_name} #{uuid} #{ip} 2>&1")
          output += "deploy_httpd_config_exitcode: #{deploy_httpd_config_exitcode.to_s}\n"
          output += "deploy_httpd_config_output: #{deploy_httpd_config_output}\n"
        end
      end
      
    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
