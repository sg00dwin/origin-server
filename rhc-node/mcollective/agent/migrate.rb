require 'rubygems'
require 'etc'
require 'fileutils'
require 'socket'
require 'parseconfig'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"

module OpenShiftMigration

  def self.rm_exists(file)
    # We want all errors reported, except for missing file...
    FileUtils.rm(file) if File.exists?(file)
  end

  def self.get_config_value(key)
    @node_config ||= ParseConfig.new('/etc/openshift/node.conf')
    val = @node_config.get_value(key)
    val.gsub!(/\\:/,":") if not val.nil?
    val.gsub!(/[ \t]*#[^\n]*/,"") if not val.nil?
    val = val[1..-2] if not val.nil? and val.start_with? "\""
    val
  end

  # Note: This method must be reentrant.  Meaning it should be able to
  # be called multiple times on the same gears.  Each time having failed
  # at any point and continue to pick up where it left off or make
  # harmless changes the 2-n times around.
  def self.migrate(uuid, namespace, version)
    unless version == "2.0.22"
      return "Invalid version: #{version}", 255
    end

    start_time = (Time.now.to_f * 1000).to_i
    
    cartridge_root_dir = "/usr/libexec/openshift/cartridges"
    libra_home = '/var/lib/openshift' #node_config.get_value('libra_dir')
    libra_server = get_config_value('BROKER_HOST')
    libra_domain = get_config_value('CLOUD_DOMAIN')
    gear_name = nil
    app_name = nil
    output = ''
    gear_home = "#{libra_home}/#{uuid}"
    begin
      gear_name = Util.get_env_var_value(gear_home, "OPENSHIFT_GEAR_NAME")
      app_name = Util.get_env_var_value(gear_home, "OPENSHIFT_APP_NAME")
    rescue Errno::ENOENT
      return "***acceptable_error_env_vars_not_found={\"gear_uuid\":\"#{uuid}\"}***\n", 0
    end
    
    exitcode = 0
    env_echos = []

    unless (File.exists?(gear_home) && !File.symlink?(gear_home))
      exitcode = 127
      output += "Application not found to migrate: #{gear_home}\n"
      return output, exitcode
    end

    if File.directory?(File.join(gear_home, "postgresql-8.4"))
      socket_value = Util.get_env_var_value(gear_home, "OPENSHIFT_POSTGRESQL_DB_SOCKET").to_s

      if (socket_value =~ /socket.+$/ )
        output += "OPENSHIFT_POSTGRESQL_DB_SOCKET: #{socket_value}\n"
        socket_value.gsub!(/socket.+$/, "socket")
        output += "Translating OPENSHIFT_POSTGRESQL_DB_SOCKET: #{socket_value}\n"
        Util.set_env_var_value(gear_home, "OPENSHIFT_POSTGRESQL_DB_SOCKET", socket_value)
      end

      cart_dir = "#{gear_home}/postgresql-8.4"

      Util.replace_in_file("#{cart_dir}/data/pg_hba.conf", "ident$", "md5")
      Util.replace_in_file("#{cart_dir}/data/postgresql.conf", "unix_socket_directory = '/tmp'", "unix_socket_directory = '#{cart_dir}/socket'")
    end

    # Many files in the app git repo may have been reset to root as a result of
    # https://bugzilla.redhat.com/show_bug.cgi?id=903152. Reset the ownership
    # of the known affected files to the gear user/group.
    app_git_dir = File.join(gear_home, "git", "#{app_name}.git")
    if File.directory?(app_git_dir)
      files_to_reset = [
        File.join(app_git_dir, "packed-refs"),
        File.join(app_git_dir, "objects", "info", "packs"),
        File.join(app_git_dir, "info", "refs")
      ]

      pack_dir = File.join(app_git_dir, "objects", "pack", "*")

      begin
        FileUtils.chown(uuid, uuid, files_to_reset)
        FileUtils.chown(uuid, uuid, Dir.glob(pack_dir))
      rescue Exception => e
        output += "ERROR: Couldn't reset git repo ownership for gear #{uuid}: #{e.message}\n#{e.backtrace}\n"
      end
    end

    env_echos.each do |env_echo|
      echo_output, echo_exitcode = Util.execute_script(env_echo)
      output += echo_output
    end
      
    total_time = (Time.now.to_f * 1000).to_i - start_time
    output += "***time_migrate_on_node_measured_from_node=#{total_time}***\n"
    return output, exitcode
  end


end


