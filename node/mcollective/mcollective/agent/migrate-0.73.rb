require 'rubygems'
require 'open4'
require 'fileutils'
require 'parseconfig'
require 'pp'

module Migration

  def self.migrate(uuid, app_name, old_app_type, namespace, version)
    node_config = ParseConfig.new('/etc/libra/node.conf')
    libra_home = '/var/lib/libra' #node_config.get_value('libra_dir')
    libra_domain = node_config.get_value('libra_domain')
    cartridge_dir = "/usr/libexec/li/cartridges"
    app_types = {'php-5.3.2' => 'php-5.3',
                 'rack-1.1.0' => 'rack-1.0', 
                 'wsgi-3.2.1' => 'wsgi-3.2',
                 'jbossas-7.0.0' => 'jbossas-7.0',
                 'perl-5.10.1' => 'perl-5.10'}
    new_app_type = app_types[old_app_type] ? app_types[old_app_type] : old_app_type 
    old_cartridge_dir = "#{cartridge_dir}/#{old_app_type}"
    new_cartridge_dir = "#{cartridge_dir}/#{new_app_type}"
    framework = old_app_type.split('-')[0]
    app_home = "#{libra_home}/#{uuid}"             
    framework_dir = "#{app_home}/#{framework}"
    old_app_dir = "#{framework_dir}/#{app_name}"
    new_app_dir = "#{app_home}/#{app_name}"
    output = ''
    exitcode = 0
    if File.exists? old_app_dir
      output += "Moving '#{old_app_dir}' to '#{new_app_dir}'\n"
      FileUtils.mv old_app_dir, new_app_dir
      if Dir["#{framework_dir}/*"].empty?
        output += "Removing empty app type dir '#{framework_dir}'\n"
        FileUtils.remove_dir framework_dir
      end
      ctl_script = "#{new_app_dir}/#{app_name}_ctl.sh"
      output += replace_in_file(ctl_script, '//', '/')
      output += replace_in_file(ctl_script, old_app_dir, new_app_dir)            
      output += replace_in_file(ctl_script, old_cartridge_dir, new_cartridge_dir)
      httpd_conf = "/etc/httpd/conf.d/libra/#{uuid}_#{namespace}_#{app_name}.conf"
      # can't replace // blindly because of http://
      output += replace_in_file(httpd_conf, old_cartridge_dir, new_cartridge_dir)
      libra_conf = "#{new_app_dir}/conf.d/libra.conf"
      output += replace_in_file(libra_conf, '//', '/')
      output += replace_in_file(libra_conf, old_app_dir, new_app_dir)
      post_receive = "#{app_home}/git/#{app_name}.git/hooks/post-receive"
      output += replace_in_file(post_receive, '//', '/')
      output += replace_in_file(post_receive, old_app_dir, new_app_dir)
      if framework == 'php'
        # can't replace // blindly because of http://
        output += replace_in_file("#{new_app_dir}/conf/php.ini", old_app_dir, new_app_dir)
      end
  
      # add ssl support
      grep_output, grep_exitcode = execute_script("grep 'ProxyPass / http://' #{httpd_conf} 2>&1")
      ip = grep_output[grep_output.index('http://') + 'http://'.length..-1]
      ip = ip[0..ip.index(':')-1]
      
      file = File.open("#{new_cartridge_dir}/info/configuration/node_ssl_template.conf", "r")
      ssl_template = nil
      begin
        ssl_template = file.read
      ensure
        file.close
      end
  
      output += "Adding ssl support to #{httpd_conf} using ip: #{ip}\n"
      file = File.open(httpd_conf, 'a')
      begin
        file.puts <<EOF

<VirtualHost *:443>
ServerName #{app_name}-#{namespace}.#{libra_domain}
ServerAdmin mmcgrath@redhat.com

#{ssl_template}

ProxyPass / http://#{ip}:8080/
ProxyPassReverse / http://#{ip}:8080/
</VirtualHost>
EOF
    
      ensure
        file.close
      end
    else
      exitcode = 127
      output += "Application not found to migrate: #{uuid}/#{framework}/#{app_name}\n"
    end
    return output, exitcode
  end
  
  
  def self.replace_in_file(file, old_value, new_value)
    output, exitcode = execute_script("sed -i \"s,#{old_value},#{new_value},g\" #{file} 2>&1")
    #TODO handle exitcode
    return "Updated '#{file}' changed '#{old_value}' to '#{new_value}'.  output: #{output}  exitcode: #{exitcode}\n"
  end
  
  def self.execute_script(cmd)
    pid, stdin, stdout, stderr = Open4::popen4(cmd)
    stdin.close
    ignored, status = Process::waitpid2 pid
    exitcode = status.exitstatus
    output = ''
    begin
      Timeout::timeout(5) do
        while (line = stdout.gets)
          output << line
        end
      end
    rescue Timeout::Error
      Log.instance.debug("execute_script WARNING - stdout read timed out")
    end
    return output, exitcode
  end

end