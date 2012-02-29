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

      if app_type == 'jenkins-1.4'

        # Remove unsed jenkins pid file
        FileUtils.rm_f "#{app_dir}/run/jenkins.pid"
        
        # Migrate and jbossas-7.0 jobs to jbossas-7
        Dir.glob('#{app_dir}/data/config.xml').each {|file|
          Util.replace_in_file("#{app_dir}/data/jobs/*/config.xml", "<builderType>jbossas-7.0</builderType>", "<builderType>jbossas-7</builderType>")
          Util.replace_in_file("#{app_dir}/data/jobs/*/config.xml", "<builderType>wsgi-3.2</builderType>", "<builderType>python-2.6</builderType>")
          Util.replace_in_file("#{app_dir}/data/jobs/*/config.xml", "<builderType>rack-1.1</builderType>", "<builderType>ruby-1.8</builderType>")
        }

        # Add security
        config_xml = "#{app_dir}/data/config.xml"
        config_xml_contents = Util.file_to_string(config_xml)

        output += "Migrating jenkins config.xml: #{config_xml}\n"
  
        users = Dir.glob("#{app_dir}/data/users/*").map do |user_path|
          File.basename(user_path)
        end

        file = File.open(config_xml, 'w')
        begin
          config_xml_contents.lines.each do |line|
            if line =~ /<authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy"\/> *$/
              file.puts "  <authorizationStrategy class=\"hudson.security.GlobalMatrixAuthorizationStrategy\">"
              users.each do |user|
                file.puts "    <permission>hudson.model.Computer.Configure:#{user}</permission>"
                file.puts "    <permission>hudson.model.Computer.Delete:#{user}</permission>"
                file.puts "    <permission>hudson.model.Hudson.Administer:#{user}</permission>"
                file.puts "    <permission>hudson.model.Hudson.Read:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Build:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Configure:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Create:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Delete:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Read:#{user}</permission>"
                file.puts "    <permission>hudson.model.Item.Workspace:#{user}</permission>"
                file.puts "    <permission>hudson.model.Run.Delete:#{user}</permission>"
                file.puts "    <permission>hudson.model.Run.Update:#{user}</permission>"
                file.puts "    <permission>hudson.model.View.Configure:#{user}</permission>"
                file.puts "    <permission>hudson.model.View.Create:#{user}</permission>"
                file.puts "    <permission>hudson.model.View.Delete:#{user}</permission>"
                file.puts "    <permission>hudson.scm.SCM.Tag:#{user}</permission>"
              end
              file.puts "  </authorizationStrategy>"
            else
              file.puts line
            end
          end
        ensure
          file.close
        end
      elsif app_type == "jbossas-7"
        if File.exists?("#{app_dir}/jbossas-7.0")
          FileUtils.mv "#{app_dir}/jbossas-7.0", "#{app_dir}/jbossas-7"
        end

        env_echos.push("echo \"export OPENSHIFT_APP_TYPE='jbossas-7'\" > #{app_home}/.env/OPENSHIFT_APP_TYPE")
        java_home = '/etc/alternatives/java_sdk_1.6.0'
        m2_home = '/etc/alternatives/maven-3.0'
        env_echos.push("echo \"export PATH=#{cartridge_dir}/info/bin/:#{cartridge_root_dir}/abstract/info/bin/:#{java_home}/bin:#{m2_home}/bin:/bin:/usr/bin\" > #{app_home}/.env/PATH")

        FileUtils.rm_f "#{app_dir}/logs"
        FileUtils.ln_s "#{app_dir}/jbossas-7/standalone/log", "#{app_dir}/logs"

        FileUtils.rm_f "#{app_dir}/jbossas-7/jboss-modules.jar"
        FileUtils.ln_s "/etc/alternatives/jbossas-7/jboss-modules.jar", "#{app_dir}/jbossas-7/jboss-modules.jar"

        FileUtils.rm_f "#{app_dir}/jbossas-7/modules"
        FileUtils.ln_s "/etc/alternatives/jbossas-7/modules", "#{app_dir}/jbossas-7/modules"

        FileUtils.rm_f "#{app_dir}/jbossas-7/bin/standalone.sh"
        FileUtils.ln_s "#{cartridge_dir}/info/bin/standalone.sh", "#{app_dir}/jbossas-7/bin/standalone.sh"

        FileUtils.rm_f "#{app_dir}/jbossas-7/bin/standalone.conf"
        FileUtils.ln_s "#{cartridge_dir}/info/bin/standalone.conf", "#{app_dir}/jbossas-7/bin/standalone.conf"
          
        git_desc_migrate_output, git_desc_migrate_exit_code = Util.execute_script(" echo \"jbossas 7 application '#{app_name}'\" > #{app_home}/git/#{app_name}.git/description")
        output += git_desc_migrate_output

        git_migrate_output, git_migrate_exit_code = Util.execute_script("/usr/bin/runcon -l s0-s0:c0.c1023 #{cartridge_dir}/info/bin/migrate_standalone_xml.sh #{app_name} #{uuid} 2>&1")
        output += git_migrate_output
        
        if git_migrate_exit_code != 0
          exitcode = git_migrate_exit_code
        end
      elsif app_type == 'ruby-1.8'
        FileUtils.rm_f "#{app_dir}/logs/production.log"
        FileUtils.ln_s "../runtime/repo/log/production.log", "#{app_dir}/logs/production.log"
      end

      env_echos.push("echo \"export OPENSHIFT_APP_STATE=#{app_dir}/runtime\" > #{app_home}/.env/OPENSHIFT_APP_STATE")

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
