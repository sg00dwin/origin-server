require 'rubygems'
require 'etc'
require 'fileutils'
require 'socket'
require 'parseconfig'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"
require File.dirname(__FILE__) + "/migrate-frontend"

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
    unless version == "2.0.24"
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

    env_echos.each do |env_echo|
      echo_output, echo_exitcode = Util.execute_script(env_echo)
      output += echo_output
    end

    # Migrate the Frontend Connection
    o, r = FrontendHttpServerMigration.migrate(uuid, gear_name, namespace)
    output << o
    if r !=0
      output << "ERROR: Failed to migrate frontend for #{uuid}\n"
      exitcode = r
    end

    python_27 = File.join(gear_home, 'python-2.7')
    python_33 = File.join(gear_home, 'python-3.3')
    sync_gears = File.join(gear_home, '.env', 'OPENSHIFT_SYNC_GEARS_DIRS')
    if (File.directory?(python_27) || File.directory?(python_33)) && !File.file?(sync_gears)
      # Cannot sync virtualenv for these cartridge types BZ918383
      File.open(sync_gears, File::WRONLY|File::TRUNC|File::CREAT) do |file|
        file.write 'export OPENSHIFT_SYNC_GEARS_DIRS=( "repo" "node_modules" "../.m2" ".openshift" "deployments" "perl5lib" "phplib" )'
      end
      output << "Override for OPENSHIFT_SYNC_GEARS_DIRS for #{uuid}\n"
    end

    total_time = (Time.now.to_f * 1000).to_i - start_time
    output += "***time_migrate_on_node_measured_from_node=#{total_time}***\n"
    return output, exitcode
  end


end


