require 'rubygems'
require 'fileutils'
require 'parseconfig'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"

module LibraMigration

  def self.get_config_value(key)
    @node_config ||= ParseConfig.new('/etc/stickshift/stickshift-node.conf')
    val = @node_config.get_value(key)
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
        if File.file?("#{fname}") && !File.symlink?("#{fname}")
          Util.replace_in_file("#{fname}", "/var/lib/libra", "/var/lib/stickshift")
          Util.replace_in_file("#{fname}", "/usr/libexec/li", "/usr/libexec/stickshift")
        end
      end

      Util.replace_in_file("#{libra_home}/.httpd.d/#{uuid}_#{namespace}_#{app_name}.conf", "/etc/httpd/conf.d/libra/" , "/etc/httpd/conf.d/stickshift/" )

      #fix builder repos
      if File.symlink?("#{app_dir}/runtime/repo")
        link_path = File.readlink("#{app_dir}/runtime/repo").gsub("/var/lib/libra", "/var/lib/stickshift")
        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{link_path} #{app_dir}/runtime/repo 2>&1")
        output += symlink_output
      end

      case app_type
      when "python-2.6", "ruby-1.8", "perl-5.10"
        FileUtils.mv("#{app_dir}/conf.d/libra.conf", "#{app_dir}/conf.d/stickshift.conf") unless File.exists?("#{app_dir}/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_dir}/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")
      when "diy-0.1"
        Util.replace_in_file("/etc/httpd/conf.d/stickshift/#{uuid}_#{namespace}_#{app_name}.conf", "raw-0.1", "diy-0.1")
        Util.replace_in_file("/etc/httpd/conf.d/stickshift/#{uuid}_#{namespace}_#{app_name}.conf", "/usr/libexec/li/cartridges", "/usr/libexec/stickshift/cartridges")
        env_echos.push("echo \"export OPENSHIFT_GEAR_TYPE='diy-0.1'\" > #{app_home}/.env/OPENSHIFT_GEAR_TYPE")
        env_echos.push("echo \"export PATH=#{cartridge_root_dir}/diy-0.1/info/bin/:#{cartridge_root_dir}/abstract/info/bin/:/sbin:/usr/sbin:/bin:/usr/bin\" > #{app_home}/.env/PATH")

        #no-op
      when "php-5.3"
        FileUtils.mv("#{app_dir}/conf.d/libra.conf", "#{app_dir}/conf.d/stickshift.conf") unless File.exists?("#{app_dir}/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_dir}/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_dir}/conf/php.ini", "/var/lib/libra", "/var/lib/stickshift")
      when "jbossas-7"
        ["/jbossas-7/standalone/configuration/standalone.xml", "/jbossas-7/standalone/configuration/standalone_xml_history/current/standalone.last.xml"].each do |fname|
          if File.exists? "#{app_dir}#{fname}"
            Util.replace_in_file("#{app_dir}#{fname}", "/var/lib/libra", "/var/lib/stickshift")
          end
        end

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/jbossas-7/info/bin/standalone.conf #{app_dir}/jbossas-7/bin/standalone.conf 2>&1")
        output += symlink_output
        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/jbossas-7/info/bin/standalone.sh #{app_dir}/jbossas-7/bin/standalone.sh 2>&1")
        output += symlink_output
        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{app_dir}/repo/.openshift/config/modules #{app_dir}/jbossas-7/standalone/configuration/modules 2>&1")
        output += symlink_output
      when 'jenkins-1.4'
        files,exitcode = Util.execute_script("fgrep -r \"/usr/libexec/li/\" #{app_dir}/data | awk 'BEGIN { FS=\":\" } { print $1 }' | grep -v 'Binary file ' | sort -u")
        files.each do |fpath|
          unless fpath.end_with?("log")
            Util.replace_in_file("#{fpath}", "/usr/libexec/li", "/usr/libexec/stickshift")
          end
        end

        files,exitcode = Util.execute_script("fgrep -r \"/var/lib/libra/\" #{app_dir}/data | awk 'BEGIN { FS=\":\" } { print $1 }' | grep -v 'Binary file ' | sort -u")
        files.each do |fpath|
          unless fpath.end_with?("log")
            Util.replace_in_file("#{fpath}", "/var/lib/libra", "/var/lib/stickshift")
          end
        end

        Util.replace_in_file("#{app_dir}/data/jobs/*/config.xml", "<builderType>raw-0.1</builderType>", "<builderType>diy-0.1</builderType>")
        if orig_jenkins_url
          Util.replace_in_file("#{app_dir}/data/config.xml", "<jenkinsUrl>.*</jenkinsUrl>", "")
          #Util.replace_in_file("#{app_dir}/data/hudson.tasks.Mailer.xml", "<hudsonUrl>.*</hudsonUrl>", "<hudsonUrl>#{jenkins_url}</hudsonUrl>")
        end

        jenkins_configs=["#{app_dir}/data/config.xml"]
        Dir.glob("#{app_dir}/data/jobs/*/config.xml") do |jobcfg|
          jenkins_configs << "#{jobcfg}"
        end

        jenkins_configs.each do |jenkins_config|
          Util.replace_in_file(jenkins_config, "OPENSHIFT_APP_NAME", "OPENSHIFT_GEAR_NAME")
          ['builderSize', 'defaultBuilderSize'].each do |builder_opt|
            { "std" => "small", "large" => "medium" }.each do |srcsize, dstsize|
              Util.replace_in_file(jenkins_config, "<#{builder_opt}>#{srcsize}<\\/#{builder_opt}>", "<#{builder_opt}>#{dstsize}</#{builder_opt}>")
            end
          end
        end

      end

      #mongodb-2.0
      if File.directory?("#{app_home}/mongodb-2.0") && !File.symlink?("#{app_home}/mongodb-2.0")
        Util.replace_in_file("#{app_home}/mongodb-2.0/etc/mongodb.conf", "/var/lib/libra", "/var/lib/stickshift")

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/mongodb-2.0/info/bin/mongodb_ctl.sh #{app_home}/mongodb-2.0/#{app_name}_mongodb_ctl.sh 2>&1")
        output += symlink_output
        FileUtils.chown(uuid,uuid,"#{app_home}/mongodb-2.0/#{app_name}_mongodb_ctl.sh")
      end

      #rockmongo-1.1
      if File.directory?("#{app_home}/rockmongo-1.1") && !File.symlink?("#{app_home}/rockmongo-1.1")
        FileUtils.mv("#{app_home}/rockmongo-1.1/conf.d/libra.conf", "#{app_home}/rockmongo-1.1/conf.d/stickshift.conf") unless File.exists?("#{app_home}/rockmongo-1.1/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_home}/rockmongo-1.1/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_home}/rockmongo-1.1/conf.d/ROCKMONGO.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_home}/rockmongo-1.1/conf/php.ini", "/var/lib/libra", "/var/lib/stickshift")

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/rockmongo-1.1/info/bin/rockmongo_ctl.sh #{app_home}/rockmongo-1.1/#{app_name}_rockmongo_ctl.sh 2>&1")
        output += symlink_output
        FileUtils.chown(uuid,uuid,"#{app_home}/rockmongo-1.1/#{app_name}_rockmongo_ctl.sh")
      end

      #phpmoadmin-1.0
      if File.directory?("#{app_home}/phpmoadmin-1.0") && !File.symlink?("#{app_home}/phpmoadmin-1.0")
        FileUtils.mv("#{app_home}/phpmoadmin-1.0/conf.d/libra.conf", "#{app_home}/phpmoadmin-1.0/conf.d/stickshift.conf") unless File.exists?("#{app_home}/phpmoadmin-1.0/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_home}/phpmoadmin-1.0/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_home}/phpmoadmin-1.0/conf.d/phpMoAdmin.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_home}/phpmoadmin-1.0/conf/php.ini", "/var/lib/libra", "/var/lib/stickshift")

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/phpmoadmin-1.0/info/configuration/disabled_pages.conf #{app_home}/phpmoadmin-1.0/conf.d/disabled_pages.conf 2>&1")
        output += symlink_output

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/phpmoadmin-1.0/info/bin/phpmoadmin_ctl.sh #{app_home}/phpmoadmin-1.0/#{app_name}_phpmoadmin_ctl.sh 2>&1")
        output += symlink_output
        FileUtils.chown(uuid,uuid,"#{app_home}/phpmoadmin-1.0/#{app_name}_phpmoadmin_ctl.sh")
      end

      #cron-1.4
      if File.directory?("#{app_home}/cron-1.4") && !File.symlink?("#{app_home}/cron-1.4")
        output += "Migratimg cron-1.4 for app #{app_name}\n"
        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/cron-1.4/info/bin/cron_runjobs.sh #{app_home}/cron-1.4/cron_runjobs.sh 2>&1")
        output += symlink_output

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/cron-1.4/info/bin/cron_ctl.sh #{app_home}/cron-1.4/#{app_name}_cron_ctl.sh 2>&1")
        output += symlink_output
        FileUtils.chown(uuid,uuid,"#{app_home}/cron-1.4/#{app_name}_cron_ctl.sh")

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{app_dir}/repo/.openshift/cron #{app_home}/cron-1.4/jobs 2>&1")
        output += symlink_output
        FileUtils.chown(uuid,uuid,"#{app_home}/cron-1.4/jobs")
      end

      #mysql-5.1
      if File.directory?("#{app_home}/mysql-5.1") && !File.symlink?("#{app_home}/mysql-5.1")
        Util.replace_in_file("#{app_home}/mysql-5.1/etc/my.cnf", "/var/lib/libra", "/var/lib/stickshift")

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/mysql-5.1/info/bin/mysql_ctl.sh #{app_home}/mysql-5.1/#{app_name}_mysql_ctl.sh 2>&1")
        output += symlink_output
        FileUtils.chown(uuid,uuid,"#{app_home}/mysql-5.1/#{app_name}_mysql_ctl.sh")
      end

      #phpmyadmin-3.4
      if File.directory?("#{app_home}/phpmyadmin-3.4") && !File.symlink?("#{app_home}/phpmyadmin-3.4")
        Util.replace_in_file("#{app_home}/phpmyadmin-3.4/conf/php.ini", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_home}/phpmyadmin-3.4/conf.d/disabled_pages.conf", "/var/lib/libra", "/var/lib/stickshift")
        FileUtils.mv("#{app_home}/phpmyadmin-3.4/conf.d/libra.conf", "#{app_home}/phpmyadmin-3.4/conf.d/stickshift.conf") unless File.exists?("#{app_home}/phpmyadmin-3.4/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_home}/phpmyadmin-3.4/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/phpmyadmin-3.4/info/bin/phpmyadmin_ctl.sh #{app_home}/phpmyadmin-3.4/#{app_name}_phpmyadmin_ctl.sh 2>&1")
        output += symlink_output
        FileUtils.chown(uuid,uuid,"#{app_home}/phpmyadmin-3.4/#{app_name}_phpmyadmin_ctl.sh")

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/phpmyadmin-3.4/info/configuration/disabled_pages.conf #{app_home}/phpmyadmin-3.4/conf.d/disabled_pages.conf 2>&1")
        output += symlink_output
      end

      #postgresql-8.4
      if File.directory?("#{app_home}/postgresql-8.4") && !File.symlink?("#{app_home}/postgresql-8.4")
        Util.replace_in_file("#{app_home}/postgresql-8.4/data/postgresql.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_home}/postgresql-8.4/data/postmaster.opts", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_home}/postgresql-8.4/data/postmaster.pid", "/var/lib/libra", "/var/lib/stickshift")

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/postgresql-8.4/info/bin/postgresql_ctl.sh #{app_home}/postgresql-8.4/#{app_name}_postgresql_ctl.sh 2>&1")
        output += symlink_output
        FileUtils.chown(uuid,uuid,"#{app_home}/postgresql-8.4/#{app_name}_postgresql_ctl.sh")
      end

      #10gen-mms-agent-0.1
      if File.directory?("#{app_home}/10gen-mms-agent-0.1") && !File.symlink?("#{app_home}/10gen-mms-agent-0.1")
        FileUtils.rm_f("#{app_home}/10gen-mms-agent-0.1/mms-agent/settings.pyc")
        FileUtils.rm_f("#{app_home}/10gen-mms-agent-0.1/mms-agent/logConfig.pyc")

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid} #{app_dir}/.openshift/mms/settings.py #{app_home}/10gen-mms-agent-0.1/mms-agent/settings.py 2>&1")
        output += symlink_output
        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/10gen-mms-agent-0.1/info/bin/10gen_mms_agent_ctl.sh #{app_home}/10gen-mms-agent-0.1/#{app_name}_10gen_mms_agent_ctl.sh 2>&1")
        output += symlink_output
        FileUtils.chown(uuid,uuid,"#{app_home}/10gen-mms-agent-0.1/#{app_name}_10gen_mms_agent_ctl.sh")
      end

      #jenkins-client-1.4 : no-op

      #metrics-0.1
      if File.directory?("#{app_home}/metrics-0.1") && !File.symlink?("#{app_home}/metrics-0.1")
        Util.replace_in_file("#{app_home}/metrics-0.1/conf.d/metrics.conf", "/var/lib/libra", "/var/lib/stickshift")
        Util.replace_in_file("#{app_home}/metrics-0.1/conf/php.ini", "/var/lib/libra", "/var/lib/stickshift")
        FileUtils.mv("#{app_home}/metrics-0.1/conf.d/libra.conf", "#{app_home}/metrics-0.1/conf.d/stickshift.conf") unless File.exists?("#{app_home}/metrics-0.1/conf.d/stickshift.conf")
        Util.replace_in_file("#{app_home}/metrics-0.1/conf.d/stickshift.conf", "/var/lib/libra", "/var/lib/stickshift")

        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid}  #{cartridge_root_dir}/embedded/metrics-0.1/info/bin/metrics_ctl.sh #{app_home}/metrics-0.1/#{app_name}_metrics_ctl.sh 2>&1")
        output += symlink_output
        FileUtils.chown(uuid,uuid,"#{app_home}/metrics-0.1/#{app_name}_metrics_ctl.sh")
      end

      if get_config_value("CREATE_APP_SYMLINKS").to_i == 1
        symlink_output, symlink_exitcode = Util.execute_script("/usr/bin/migration-symlink-as-user #{app_name} #{uuid} #{app_home} #{libra_home}/#{app_name}-#{namespace} 2>&1")
        output += symlink_output
        FileUtils.chown(uuid,uuid,"#{libra_home}/#{app_name}-#{namespace}")
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
