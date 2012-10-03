require 'rubygems'
require 'etc'
require 'fileutils'
require 'socket'
require 'parseconfig'
require 'selinux'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"

module OpenShiftMigration

  def self.rm_exists(file)
    # We want all errors reported, except for missing file...
    FileUtils.rm(file) if File.exists?(file)
  end

  def self.get_config_value(key)
    @node_config ||= ParseConfig.new('/etc/stickshift/stickshift-node.conf')
    val = @node_config.get_value(key)
    val.gsub!(/\\:/,":") if not val.nil?
    val.gsub!(/[ \t]*#[^\n]*/,"") if not val.nil?
    val = val[1..-2] if not val.nil? and val.start_with? "\""
    val
  end

  def self.typed_cleanup(app_name, gear_home, gear_type, cart_ns)
    translate_map = {
        "OPENSHIFT_GEAR_CTL_SCRIPT" => "/usr/libexec/stickshift/cartridges/#{gear_type}/info/bin/app_ctl.sh",
        "OPENSHIFT_GEAR_DIR" => "#{gear_home}/#{gear_type}",
        "OPENSHIFT_LOG_DIR" => "$OPENSHIFT_#{cart_ns}_LOG_DIR",
        "OPENSHIFT_RUN_DIR" => "#{gear_home}/#{gear_type}/run",
        "OPENSHIFT_RUNTIME_DIR" => "#{gear_home}/#{gear_type}/runtime",
        "OPENSHIFT_GEAR_TYPE" => "#{gear_type}"
    }

    Util.add_env_vars_to_typeless_translated(gear_home, translate_map)

    Util.rm_env_var_value(gear_home,
        "OPENSHIFT_GEAR_CTL_SCRIPT",
        "OPENSHIFT_GEAR_DIR",
        "OPENSHIFT_LOG_DIR",
        "OPENSHIFT_RUN_DIR",
        "OPENSHIFT_RUNTIME_DIR",
        "OPENSHIFT_GEAR_TYPE"
        )

    Dir[File.join(gear_home, '*', "#{app_name}_ctl.sh")].each { |entry|
      rm_exists(entry)
    }

    Dir[File.join(gear_home, '*')].each { |entry|
      rm_exists(entry) if File.symlink?(entry)
    }
  end

  def self.typeless_log_dir(gear_home, gear_type, cart_ns)
    Util.set_env_var_value(gear_home, "OPENSHIFT_#{cart_ns}_LOG_DIR",
        "#{gear_home}/#{gear_type}/logs/")
  end

  def self.typeless_network_env_vars(gear_home, gear_type, cart_ns)
    Util.cp_env_var_value(gear_home, "OPENSHIFT_INTERNAL_IP", "OPENSHIFT_#{cart_ns}_IP")
    Util.cp_env_var_value(gear_home, "OPENSHIFT_INTERNAL_PORT", "OPENSHIFT_#{cart_ns}_PORT")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_PROXY_PORT", "OPENSHIFT_#{cart_ns}_PROXY_PORT")
  end

  def self.typeless_framework(app_name, gear_home, gear_type, cart_ns)
    typeless_log_dir(gear_home, gear_type, cart_ns)
    typeless_network_env_vars(gear_home, gear_type, cart_ns)
    typed_cleanup(app_name, gear_home, gear_type, cart_ns)
  end

  def self.typeless_embedded(app_name, gear_home, gear_type, cart_ns)
    Util.rm_env_var_value(gear_home,
        "OPENSHIFT_#{cart_ns}_CTL_SCRIPT",
        "OPENSHIFT_#{cart_ns}_GEAR_DIR"
        )
    Util.set_env_var_value(gear_home, "OPENSHIFT_#{cart_ns}_PORT", "8080")
    Util.set_env_var_value(gear_home, "OPENSHIFT_#{cart_ns}_LOG_DIR", "#{gear_home}/#{gear_type}/logs/")
  end

  def self.typeless_jboss(app_name, gear_home, gear_type, cart_ns)
    typeless_framework(app_name, gear_home, gear_type, cart_ns)

    Util.mv_env_var_value(gear_home, "OPENSHIFT_JBOSS_CLUSTER",                   "OPENSHIFT_#{cart_ns}_CLUSTER")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_JBOSS_CLUSTER_PORT",              "OPENSHIFT_#{cart_ns}_CLUSTER_PORT")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_JBOSS_CLUSTER_PROXY_PORT",        "OPENSHIFT_#{cart_ns}_CLUSTER_PROXY_PORT")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_JBOSS_CLUSTER_REMOTING",          "OPENSHIFT_#{cart_ns}_CLUSTER_REMOTING")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_JBOSS_MESSAGING_PORT",            "OPENSHIFT_#{cart_ns}_MESSAGING_PORT")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_JBOSS_MESSAGING_THROUGHPUT_PORT", "OPENSHIFT_#{cart_ns}_MESSAGING_THROUGHPUT_PORT")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_JBOSS_REMOTING_PORT",             "OPENSHIFT_#{cart_ns}_REMOTING_PORT")
  end

  def self.typeless_database(app_name, gear_home, gear_type, cart_ns, tag = "DB")
    Util.rm_env_var_value(gear_home,
        "OPENSHIFT_#{tag}_CTL_SCRIPT",
        "OPENSHIFT_#{tag}_TYPE"
        )
    Util.mv_env_var_value(gear_home, "OPENSHIFT_#{tag}_HOST",     "OPENSHIFT_#{cart_ns}_DB_HOST")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_#{tag}_PASSWORD", "OPENSHIFT_#{cart_ns}_DB_PASSWORD")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_#{tag}_PORT",     "OPENSHIFT_#{cart_ns}_DB_PORT")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_#{tag}_SOCKET",   "OPENSHIFT_#{cart_ns}_DB_SOCKET")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_#{tag}_URL",      "OPENSHIFT_#{cart_ns}_DB_URL")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_#{tag}_USERNAME", "OPENSHIFT_#{cart_ns}_DB_USERNAME")
    Util.mv_env_var_value(gear_home, "OPENSHIFT_#{tag}_PROXY_PORT", "OPENSHIFT_#{cart_ns}_DB_PROXY_PORT")

    translate_db_vars_map = {
      "OPENSHIFT_#{tag}_HOST"      =>  "$OPENSHIFT_#{cart_ns}_DB_HOST",
      "OPENSHIFT_#{tag}_PASSWORD"  =>  "$OPENSHIFT_#{cart_ns}_DB_PASSWORD",
      "OPENSHIFT_#{tag}_PORT"      =>  "$OPENSHIFT_#{cart_ns}_DB_PORT",
      "OPENSHIFT_#{tag}_SOCKET"    =>  "$OPENSHIFT_#{cart_ns}_DB_SOCKET",
      "OPENSHIFT_#{tag}_URL"       =>  "$OPENSHIFT_#{cart_ns}_DB_URL",
      "OPENSHIFT_#{tag}_USERNAME"  =>  "$OPENSHIFT_#{cart_ns}_DB_USERNAME"
    }

    Util.append_env_vars_to_typeless_translated(gear_home, translate_db_vars_map)
  end

  def self.typeless_mysql(app_name, gear_home, gear_type, cart_ns)
    typeless_database(app_name, gear_home, gear_type, cart_ns, tag = "DB")
    Util.rm_env_var_value(gear_home,
        "OPENSHIFT_DB_MYSQL_51_DUMP_CLEANUP",
        "OPENSHIFT_DB_MYSQL_51_DUMP",
        "OPENSHIFT_DB_MYSQL_51_EMBEDDED_TYPE",
        "OPENSHIFT_DB_MYSQL_51_RESTORE"
        )
    Dir[File.join(gear_home, '*', "#{app_name}_mysql_ctl.sh")].each { |entry|
      rm_exists(entry)
    }
  end

  def self.typeless_postgresql(app_name, gear_home, gear_type, cart_ns)
    typeless_database(app_name, gear_home, gear_type, cart_ns, tag = "DB")
    Util.rm_env_var_value(gear_home,
        "OPENSHIFT_DB_POSTGRESQL_84_DUMP_CLEANUP",
        "OPENSHIFT_DB_POSTGRESQL_84_DUMP",
        "OPENSHIFT_DB_POSTGRESQL_84_EMBEDDED_TYPE",
        "OPENSHIFT_DB_POSTGRESQL_84_RESTORE"
        )

    Dir[File.join(gear_home, '*', "#{app_name}_postgresql_ctl.sh")].each { |entry|
      rm_exists(entry)
    }
  end

  # Transformations on namespace
  def self.xform_ent_mongodb_22(input)
    output=input.clone
    { "mongodb-2.0" => "mongodb-2.2", "MONGODB_20" => "MONGODB_22" }.each do |src,dst|
      output.gsub!(src,dst)
    end
    if input != output
      yield output
    end
    return output
  end

  def self.typeless_mongodb(app_name, gear_home, gear_type, cart_ns)
    typeless_database(app_name, gear_home, gear_type, cart_ns, tag = "NOSQL_DB")
    Util.rm_env_var_value(gear_home,
        "OPENSHIFT_NOSQL_DB_MONGODB_22_DUMP_CLEANUP",
        "OPENSHIFT_NOSQL_DB_MONGODB_22_DUMP",
        "OPENSHIFT_NOSQL_DB_MONGODB_22_EMBEDDED_TYPE",
        "OPENSHIFT_NOSQL_DB_MONGODB_22_RESTORE"
        )

    Dir[File.join(gear_home, '*', "#{app_name}_mongodb_ctl.sh")].each { |entry|
      rm_exists(entry)
    }
  end

  # Handle gear conversion from mongodb-2.0 to mongodb-2.2
  def self.migrate_mongodb_22(uuid, gear_home, gear_name)
    output = ""

    output+="Mongodb migration for gear #{uuid}\n"

    # The mongodb-2.0 directory must be ahead of its subdirectories
    [ File.join(gear_home, "mongodb-2.0"),
      File.join(gear_home, gear_name),
      File.join(gear_home, "mongodb-2.0", "etc", "mongodb.conf"),
      File.join(gear_home, "mongodb-2.0", "#{gear_name}_mongodb_ctl.sh"),
      File.join(gear_home, "mongodb-2.0", "#{gear_name}_ctl.sh"),
      Dir.glob(File.join(gear_home, ".env", ".uservars", "*")),
      Dir.glob(File.join(gear_home, ".env", "*")),
      Dir.glob(File.join(gear_home, "..", ".httpd.d", "#{uuid}_*.conf")),
      Dir.glob(File.join(gear_home, "..", ".httpd.d", "#{uuid}_*/*.conf"))
    ].flatten.sort { |i,j| i.length <=> j.length }.each do |entry|

      # Fix the entry itself and correct file name for below.
      entry = self.xform_ent_mongodb_22(entry) do |dentry|
        if File.exist?(entry) and not File.exist?(dentry)
          output+="Rename: #{entry} -> #{dentry}\n"
          File.rename(entry, dentry)
        end
      end

      # Fix symlink targets or file contents.  Do not edit files
      # through a symlink to avoid the risk of accidentally making
      # edits outside the gear.
      if File.symlink?(entry)
        self.xform_ent_mongodb_22(File.readlink(entry)) do |dstlink|
          output+="Fix Symlink: #{entry} -> #{dstlink}\n"
          File.unlink(entry)
          File.symlink(dstlink,entry)
          mcs_label = Util.get_mcs_level(uuid)
          output+="Fixing selinux MCS label: #{entry} -> system_u:object_r:libra_var_lib_t:#{mcs_label}"
          %x[ chcon -h -u system_u -r object_r -t libra_var_lib_t -l #{mcs_label} #{entry} ]
        end
      elsif File.file?(entry)
        File.open(entry, File::RDWR) do |f|
          self.xform_ent_mongodb_22(f.read) do |dstbuf|
            output+="File contents: #{entry}\n"
            f.seek(0)
            f.truncate(0)
            f.write(dstbuf)
          end
        end
      end
    end

    return output
  end

  # Disable the Jenkins SSHD server on all instances, regardless of
  # current user preferences.
  def self.migrate_jenkins_sshd(gear_home, cartridge_dir)
    sshd_conf_basename = "org.jenkinsci.main.modules.sshd.SSHD.xml"
    
    gear_sshd_conf = File.join(gear_home, "app-root", "data", sshd_conf_basename)
    cart_sshd_conf = File.join(cartridge_dir, "info", "configuration", "jenkins-pre-deploy", sshd_conf_basename)

    rm_exists(gear_sshd_conf)
    FileUtils.copy(cart_sshd_conf, gear_sshd_conf)
  end

  # Note: This method must be reentrant.  Meaning it should be able to
  # be called multiple times on the same gears.  Each time having failed
  # at any point and continue to pick up where it left off or make
  # harmless changes the 2-n times around.
  def self.migrate(uuid, namespace, version)
    if version == "2.0.18"

      # See jenkins below for an example of a specialization for a cartridge type
      frameworks = {
        '10gen-mms-agent-0.1' => '10GENMMSAGENT',
        'diy-0.1'             => 'DIY',
        'jenkins-client-1.4'  => 'JENKINSCLIENT',
        'nodejs-0.6'          => 'NODEJS',
        'perl-5.10'           => 'PERL',
        'php-5.3'             => 'PHP',
        'python-2.6'          => 'PYTHON',
        'ruby-1.8'            => 'RUBY',
        'ruby-1.9'            => 'RUBY',
        'zend-5.6'            => 'ZEND'
      }

      jbosses = {
        'jbossas-7'    => 'JBOSSAS',
        'jbosseap-6.0' => 'JBOSSEAP'
      }

      libra_home = '/var/lib/stickshift' #node_config.get_value('libra_dir')
      libra_server = get_config_value('BROKER_HOST')
      libra_domain = get_config_value('CLOUD_DOMAIN')
      gear_home = "#{libra_home}/#{uuid}"
      gear_name = Util.get_env_var_value(gear_home, "OPENSHIFT_GEAR_NAME")
      app_name = Util.get_env_var_value(gear_home, "OPENSHIFT_APP_NAME")
      output = ''
      exitcode = 0

      if (File.exists?(gear_home) && !File.symlink?(gear_home))
        cartridge_root_dir = "/usr/libexec/stickshift/cartridges"

        frameworks.each { |k, v|
          if File.directory?(File.join(gear_home, k))
            begin
              typeless_framework(app_name, gear_home, k, v)
            rescue => e
              output+="Exception caught in #{k} framework migration in gear #{gear_home}:\n"
              output+="#{e}\n"
              exitcode=101
            end
          end
        }

        if File.directory?(File.join(gear_home, 'python-2.6'))
          output += migrate_python(gear_home, uuid)
        end

        jbosses.each { |k, v|
          if File.directory?(File.join(gear_home, k))
            begin
              typeless_jboss(app_name, gear_home, k, v)
            rescue => e
              output+="Exception caught in #{k} framework migration in gear #{gear_home}:\n"
              output+="#{e}\n"
              exitcode=101
            end
          end
        }

        if File.directory?(File.join(gear_home, 'mysql-5.1'))
          begin
            typeless_mysql(app_name, gear_home, 'mysql-5.1', 'MYSQL')
          rescue => e
            output+="Exception caught in mysql-5.1 migration in gear #{gear_home}:\n"
            output+="#{e}\n"
            exitcode=101
          end
        end

        if File.directory?(File.join(gear_home, 'postgresql-8.4'))
          begin
            typeless_postgresql(app_name, gear_home, 'postgresql-8.4', 'POSTGRESQL')
          rescue => e
            output+="Exception caught in postgresql-8.4 migration in gear #{gear_home}:\n"
            output+="#{e}\n"
            exitcode=101
          end
        end

        if File.directory?(File.join(gear_home, 'mongodb-2.0'))
          begin
          	output+=self.migrate_mongodb_22(uuid, gear_home, gear_name)
          rescue => e
            output+="Exception caught in mongo-2.0 migration:\n"
            output+="#{e}\n"
            exitcode=100
          end        
        end

        if File.directory?(File.join(gear_home, 'mongodb-2.2'))
          begin
            typeless_mongodb(app_name, gear_home, 'mongodb-2.2', 'MONGODB')
          rescue => e
            output+="Exception caught in mongodb-2.2 migration in gear #{gear_home}:\n"
            output+="#{e}\n"
            exitcode=101
          end
		    end

        if File.directory?(File.join(gear_home, 'haproxy-1.4'))
          begin
            typeless_log_dir(gear_home, 'haproxy-1.4', 'HAPROXY')
          rescue => e
            output+="Exception caught in haproxy-1.4 migration in gear #{gear_home}:\n"
            output+="#{e}\n"
            exitcode=101
          end
        end

        begin
          # Cleanup DB connection vars, if any. These will be recreated on running
          # hascaledb.rb migration script
          Dir[File.join(gear_home, '.env', '.uservars', "OPENSHIFT_DB_*"),
              File.join(gear_home, '.env', '.uservars', "OPENSHIFT_NOSQL_DB_*")].each { |entry|
            rm_exists(entry)
          }
        rescue => e
          output+="Exception caught in cleaning up db connections in gear #{gear_home}:\n"
          output+="#{e}\n"
          exitcode=101
        end

        if File.directory?(File.join(gear_home, 'metrics-0.1'))
          begin
            typeless_embedded(app_name, gear_home, 'metrics-0.1', 'METRICS')
          rescue => e
            output+="Exception caught in metrics-0.1 migration in gear #{gear_home}:\n"
            output+="#{e}\n"
            exitcode=101
          end
        end

        if File.directory?(File.join(gear_home, 'phpmyadmin-3.4'))
          begin
            typeless_embedded(app_name, gear_home, 'phpmyadmin-3.4', 'PHPMYADMIN')
            Dir[File.join(gear_home, '*', "#{app_name}_phpmyadmin_ctl.sh")].each { |entry|
              rm_exists(entry)
            }
          rescue => e
            output+="Exception caught in phpmyadmin-3.4 migration in gear #{gear_home}:\n"
            output+="#{e}\n"
            exitcode=101
          end
        end

        if File.directory?(File.join(gear_home, 'rockmongo-1.1'))
          begin
            typeless_embedded(app_name, gear_home, 'rockmongo-1.1', 'ROCKMONGO')
            Dir[File.join(gear_home, '*', "#{app_name}_rockmongo_ctl.sh")].each { |entry|
              rm_exists(entry)
            }
          rescue => e
            output+="Exception caught in rockmongo-1.1 migration in gear #{gear_home}:\n"
            output+="#{e}\n"
            exitcode=101
          end
        end

        if File.directory?(File.join(gear_home, 'cron-1.4'))
          begin
            rm_exists(gear_home,
                "OPENSHIFT_BATCH_CRON_14_EMBEDDED_TYPE",
                "OPENSHIFT_BATCH_CTL_SCRIPT",
                "OPENSHIFT_BATCH_TYPE"
                )
          rescue => e
            output+="Exception caught in cron-1.4 migration in gear #{gear_home}:\n"
            output+="#{e}\n"
            exitcode=101
          end
        end

        if File.directory?(File.join(gear_home, "jenkins-1.4"))
          begin
            typeless_framework(app_name, gear_home, 'jenkins-1.4', 'JENKINS')
            command =%Q|sed -i "s#~/\\([A-Za-z0-9]\\+\\)/repo#~/app-root/runtime/repo#g;\\
                                s#~/\\([A-Za-z0-9]\\+\\)/node_modules#~/nodejs-0.6/node_modules#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/node_modules#nodejs-0.6/node_modules#g;\\
                                s#~/#{gear_name}/node_modules#~/nodejs-0.6/node_modules#g;\\
                                s#~/\\([A-Za-z0-9]\\+\\)/perl5lib#~/perl-5.10/perl5lib#g;\\
                                s#~/#{gear_name}/perl5lib#~/perl-5.10/perl5lib#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/perl5lib#perl-5.10/perl5lib#g;\\
                                s#~/\\([A-Za-z0-9]\\+\\)/phplib#~/php-5.3/phplib#g;\\
                                s#~/#{gear_name}/phplib#~/php-5.3/phplib#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/phplib#php-5.3/phplib#g;\\
                                s#~/\\([A-Za-z0-9]\\+\\)/virtenv#~/python-2.6/virtenv#g;\\
                                s#~/#{gear_name}/virtenv#~/python-2.6/virtenv#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/virtenv#python-2.6/virtenv#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/nodejs-0.6#nodejs-0.6#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/jbossas-7#jbossas-7#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/jbosseap-6.0#jbosseap-6.0#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/perl-5.10#perl-5.10#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/php-5.3#php-5.3#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/python-2.6#python-2.6#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/ruby-1.8#ruby-1.8#g;\\
                                s#\\${OPENSHIFT_GEAR_NAME}/ruby-1.9#ruby-1.9#g;"\\
                                #{gear_home}/jenkins-1.4/data/jobs/*/config.xml| 
            system(command)

            self.migrate_jenkins_sshd(gear_home, File.join(cartridge_root_dir, 'jenkins-1.4'))
          rescue => e
            output+="Exception caught in jenkins-1.4 migration in gear #{gear_home}:\n"
            output+="#{e}\n"
            exitcode=101
          end
        end

        env_echos = []

        env_echos.each do |env_echo|
          echo_output, echo_exitcode = Util.execute_script(env_echo)
          output += echo_output
        end
      else
        exitcode = 127
        output += "Application not found to migrate: #{gear_home}\n"
      end
      return output, exitcode
    else
      return "Invalid version: #{version}", 255
    end
  end
  
  def self.migrate_python(gear_home, uuid)
    conf_file = File.join(gear_home, 'python-2.6', 'conf.d', 'stickshift.conf')
    text = File.read(conf_file)
    result = text.gsub("WSGIPassAuthorization On", "WSGIPassAuthorization On\nWSGIProcessGroup #{uuid}\nWSGIDaemonProcess #{uuid} user=#{uuid} group=#{uuid} processes=2 threads=25 python-path=\"#{gear_dir}/repo/libs:#{gear_dir}/repo/wsgi:#{gear_dir}/virtenv/lib/python2.6/")
    File.open(conf_file, "w") {|file| file.puts result}
    
    output = ''
    output += "migrate_python #{conf_file}"
    return output
  end
end
