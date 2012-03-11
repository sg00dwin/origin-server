require 'rubygems'
require 'fileutils'
require 'parseconfig'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"

module LibraMigration

  def self.get_config_value(key)
    @node_config ||= ParseConfig.new('/etc/stickshift/stickshift-node.conf')    
    val = @node_config.get(key)
    val.gsub!(/\\:/,":") if not val.nil?
    val.gsub!(/[ \t]*#[^\n]*/,"") if not val.nil?
    val = val[1..-2] if not val.nil? and val.start_with? "\""
    val
  end

  def self.migrate(uuid, app_name, app_type, namespace, version)

    libra_home = '/var/lib/stickshift' #node_config.get_value('libra_dir')
    libra_server = get_config_value('BROKER_HOST')
    libra_domain = get_config_value('CLOUD_DOMAIN')
    app_home = "#{libra_home}/#{uuid}"
    app_dir = "#{app_home}/#{app_name}"
    output = ''
    exitcode = 0
    if (File.exists?(app_home) && !File.symlink?(app_home))
      cartridge_root_dir = "/usr/libexec/stickshift/cartridges"
      cartridge_dir = "#{cartridge_root_dir}/#{app_type}"

      env_echos = []
        
      jenkins_url = nil
      orig_jenkins_url = nil
      if File.exists?("#{app_home}/.env/JENKINS_URL")
        jenkins_url = Util.get_env_var_value(app_home, "JENKINS_URL")
        if jenkins_url.start_with?("http://")
          orig_jenkins_url = jenkins_url
          jenkins_url = "https://#{jenkins_url[7..-1]}"
          env_echos.push("echo \"export JENKINS_URL='#{jenkins_url}'\" > #{app_home}/.env/JENKINS_URL")
        end
      end
      
      Dir.glob("#{app_home}/.env/*") do |fname|
        if File.file?("#{app_home}/.env/#{fname}") && !File.symlink?("#{app_home}/.env/#{fname}")
          Util.replace_in_file("#{app_home}/.env/#{fname}", "/var/lib/libra", "/var/lib/stickshift")
          Util.replace_in_file("#{app_home}/.env/#{fname}", "/usr/libexec/li", "/usr/libexec/stickshift")
        end
      end

      case app_type
      when "python-2.6", "ruby-1.8", "perl-5.10"
        FileUtils.mv("#{app_dir}/conf.d/libra.conf", "#{app_dir}/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_dir}/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")
      when "raw-0.1"
        #no-op
      when "php-5.3"
        FileUtils.mv("#{app_dir}/conf.d/libra.conf", "#{app_dir}/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_dir}/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_dir}/conf/php.ini", "/var/lib/libra", "/var/lib/stickshift")
      when "jbossas-7.0"        
        ["/jbossas-7.0/standalone/configuration/standalone.xml", "/jbossas-7.0/standalone/configuration/standalone_xml_history/current/standalone.last.xml",
        "/jbossas-7.0/standalone/log/boot.log", "/jbossas-7.0/standalone/log/server.log", "/jbossas-7.0/standalone/tmp/#{app_name}.log",
        "/logs/boot.log", "/logs/server.log"].each do |fname|
          if File.exists? "#{app_dir}#{fname}"
            Util.replace_in_file("#{app_dir}#{fname}", "/var/lib/libra", "/var/lib/stickshift")
          end
        end

        ["/jbossas-7.0/standalone/log/boot.log", "/jbossas-7.0/standalone/tmp/#{app_name}.log", "/logs/boot.log"].each do |fname|
          if File.exists? "#{app_dir}#{fname}"
            Util.replace_in_file("#{app_dir}#{fname}", "/usr/libexec/li", "/usr/libexec/stickshift")
          end
        end
      when 'jenkins-1.4'
        #Util.replace_in_file("#{app_dir}/data/jobs/*/config.xml", "<builderType>raw-0.1</builderType>", "<builderType>diy-0.1</builderType>")
        if orig_jenkins_url
          Util.replace_in_file("#{app_dir}/data/config.xml", "<jenkinsUrl>.*</jenkinsUrl>", "")
          #Util.replace_in_file("#{app_dir}/data/hudson.tasks.Mailer.xml", "<hudsonUrl>.*</hudsonUrl>", "<hudsonUrl>#{jenkins_url}</hudsonUrl>")
        end
      end
      
      #mongodb-2.0
      if File.directory?("#{app_dir}/mongodb-2.0") && !File.symlink?("#{app_dir}/mongodb-2.0")
        Util.replace_in_file("#{app_dir}/mongodb-2.0/etc/mongodb.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_dir}/mongodb-2.0/log/mongodb.log", "/var/lib/libra", "/var/lib/stickshift")
      end
      
      #rockmongo-1.1
      if File.directory?("#{app_dir}/rockmongo-1.1") && !File.symlink?("#{app_dir}/rockmongo-1.1")
        FileUtils.mv("#{app_dir}/rockmongo-1.1/conf.d/libra.conf", "#{app_dir}/rockmongo-1.1/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_dir}/rockmongo-1.1/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_dir}/rockmongo-1.1/conf.d/ROCKMONGO.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_dir}/rockmongo-1.1/conf/php.ini", "/var/lib/libra", "/var/lib/stickshift")
        
        FileUtils.rm("#{app_dir}/rockmongo-1.1/#{app_name}_rockmongo_ctl.sh")
        FileUtils.cp("#{cartridge_root_dir}/embedded/rockmongo-1.1/info/bin/rockmongo_ctl.sh", "#{app_dir}/rockmongo-1.1/#{app_name}_rockmongo_ctl.sh")
      end
      
      #phpmoadmin-1.0
      if File.directory?("#{app_dir}/phpmoadmin-1.0") && !File.symlink?("#{app_dir}/phpmoadmin-1.0")
        FileUtils.mv("#{app_dir}/phpmoadmin-1.0/conf.d/libra.conf", "#{app_dir}/phpmoadmin-1.0/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_dir}/phpmoadmin-1.0/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_dir}/phpmoadmin-1.0/conf.d/phpMoAdmin.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_dir}/phpmoadmin-1.0/conf/php.ini", "/var/lib/libra", "/var/lib/stickshift")
        
        FileUtils.rm("#{app_dir}/phpmoadmin-1.0/#{app_name}_phpmoadmin_ctl.sh")
        FileUtils.cp("#{cartridge_root_dir}/embedded/phpmoadmin-1.0/info/bin/phpmoadmin_ctl.sh", "phpmoadmin-1.0/#{app_name}_phpmoadmin_ctl.sh")
      end
      
      #cron-1.4
      if File.directory?("#{app_dir}/cron-1.4") && !File.symlink?("#{app_dir}/cron-1.4")
        FileUtils.rm("#{app_dir}/cron-1.4/cron_runjobs.sh")
        FileUtils.cp("#{cartridge_root_dir}/embedded/cron-1.4/info/bin/cron_runjobs.sh", "#{app_dir}/cron-1.4/cron_runjobs.sh")
        
        FileUtils.rm("#{app_dir}/cron-1.4/#{app_name}_cron_ctl.sh")
        FileUtils.cp("#{cartridge_root_dir}/embedded/cron-1.4/info/bin/cron_ctl.sh", "#{app_dir}/cron-1.4/#{app_name}_cron_ctl.sh")
      end
      
      #mysql-5.1
      if File.directory?("#{app_dir}/mysql-5.1") && !File.symlink?("#{app_dir}/mysql-5.1")
        Util.replace_in_file("#{app_dir}/mysql-5.1/etc/my.cnf", "/var/lib/libra", "/var/lib/stickshift")
        Dir.glob("#{app_dir}/mysql-5.1/log/*").each do |log_file_name|
          Util.replace_in_file("#{app_dir}/mysql-5.1/log/#{log_file_name}", "/var/lib/libra", "/var/lib/stickshift")
        end
        
        FileUtils.rm("#{app_dir}/mysql-5.1/#{app_name}_mysql_ctl.sh")
        FileUtils.cp("#{cartridge_root_dir}/embedded/mysql-5.1/info/bin/mysql_ctl.sh", "#{app_dir}/mysql-5.1/#{app_name}_mysql_ctl.sh")
      end
      
      #phpmyadmin-3.4
      if File.directory?("#{app_dir}/phpmyadmin-3.4") && !File.symlink?("#{app_dir}/phpmyadmin-3.4")
        Util.replace_in_file("#{app_dir}/phpmyadmin-3.4/conf/php.ini", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_dir}/phpmyadmin-3.4/conf.d/disabled_pages.conf", "/var/lib/libra", "/var/lib/stickshift")
        FileUtils.mv("#{app_dir}/phpmyadmin-3.4/conf.d/libra.conf", "#{app_dir}/phpmyadmin-3.4/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_dir}/phpmyadmin-3.4/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")
        
        FileUtils.rm("#{app_dir}/phpmyadmin-3.4/#{app_name}_phpmyadmin_ctl.sh")
        FileUtils.cp("#{cartridge_root_dir}/embedded/phpmyadmin-3.4/info/bin/phpmyadmin_ctl.sh", "#{app_dir}/phpmyadmin-3.4/#{app_name}_phpmyadmin_ctl.sh")
      end
      
      #postgresql-8.4
      if File.directory?("#{app_dir}/postgresql-8.4") && !File.symlink?("#{app_dir}/postgresql-8.4")
        Util.replace_in_file("#{app_dir}/postgresql-8.4/data/postgresql.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_dir}/postgresql-8.4/data/postmaster.opts", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_dir}/postgresql-8.4/data/postmaster.pid", "/var/lib/libra", "/var/lib/stickshift")
        
        FileUtils.rm("#{app_dir}/postgresql-8.4/#{app_name}_postgresql_ctl.sh")
        FileUtils.cp("#{cartridge_root_dir}/embedded/postgresql-8.4/info/bin/postgresql_ctl.sh", "#{app_dir}/postgresql-8.4/#{app_name}_postgresql_ctl.sh")
      end
      
      #10gen-mms-agent-0.1 : no-op
      
      #metrics-0.1
      if File.directory?("#{app_dir}/metrics-0.1") && !File.symlink?("#{app_dir}/metrics-0.1")
        Util.replace_in_file("#{app_dir}/metrics-0.1/conf.d/metrics.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_dir}/metrics-0.1/conf/php.ini", "/var/lib/libra", "/var/lib/stickshift")
        FileUtils.mv("#{app_dir}/metrics-0.1/conf.d/libra.conf", "#{app_dir}/metrics-0.1/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_dir}/metrics-0.1/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")
        
        FileUtils.rm("#{app_dir}/metrics-0.1/#{app_name}_metrics_ctl.sh")
        FileUtils.cp("#{cartridge_root_dir}/embedded/metrics-0.1/info/bin/metrics_ctl.sh", "#{app_dir}/metrics-0.1/#{app_name}_metrics_ctl.sh")
      end

      env_echos.each do |env_echo|
        echo_output, echo_exitcode = Util.execute_script(env_echo)
        output += echo_output
      end

      echo_output, echo_exitcode = Util.execute_script("/usr/bin/rhc-app-gear-xlate #{app_home}/.env")
      output += echo_output

    else
      exitcode = 127
      output += "Application not found to migrate: #{app_home}\n"
    end
    return output, exitcode
  end
end
