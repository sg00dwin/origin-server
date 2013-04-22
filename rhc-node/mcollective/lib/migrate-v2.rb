require 'rubygems'
require 'etc'
require 'fileutils'
require 'socket'
require 'parseconfig'
require 'pp'

require_relative "migrate-util"
require_relative "migrate-v2-diy-0.1"
require_relative "migrate-v2-jbossas-7"
require_relative "migrate-v2-jbosseap-6.0"
require_relative "migrate-v2-jbossews-1.0"
require_relative "migrate-v2-jbossews-2.0"
require_relative "migrate-v2-nodejs-0.6"
require_relative "migrate-v2-perl-5.10"
require_relative "migrate-v2-php-5.3"
require_relative "migrate-v2-python-2.6"
require_relative "migrate-v2-ruby-1.8"
require_relative "migrate-v2-ruby-1.9"
require_relative "migrate-v2-zend-5.6"
require_relative "migrate-v2-metrics-0.1"
require_relative "migrate-v2-jenkins-1.4"
require_relative "migrate-v2-jenkins-client-1.4"
require_relative "migrate-v2-mongodb-2.2"
require_relative "migrate-v2-rockmongo-1.1"
require_relative "migrate-v2-10gen-mms-agent-0.1"
require_relative "migrate-v2-mysql-5.1"
require_relative "migrate-v2-phpmyadmin-3.4"
require_relative "migrate-v2-postgresql-8.4"

require 'openshift-origin-node/utils/sdk'
require 'openshift-origin-node/model/cartridge_repository'
require 'openshift-origin-node/utils/cgroups'
require 'openshift-origin-node/model/unix_user'
require 'openshift-origin-common'

module OpenShift
  class V2MigrationCartridgeModel < V2CartridgeModel
    def process_cartridges(cartridge_dir = nil) # : yields cartridge_path
      if cartridge_dir
        cart_dir = File.join(@user.homedir, cartridge_dir)
        yield cart_dir if File.exist?(cart_dir)
        return
      end

      Dir[PathUtils.join(@user.homedir, "*")].each do |cart_dir|
        # Ignore directories with '-' to avoid both app-root as well as any
        # V1 cartridge instance directories
        next if cart_dir.include?('-') || cart_dir.end_with?('git') ||
            (not File.directory? cart_dir)
        yield cart_dir
      end
    end
  end
end

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

  # Note: This method must be reentrant, meaning it should be able to
  # be called multiple times on the same gears.  Each time having failed
  # at any point and continue to pick up where it left off or make
  # harmless changes the 2-n times around.
  def self.migrate(uuid, namespace, version)
    unless version == "2.0.26"
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

    output += 'Beginning V1 -> V2 migration'

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

    stop_gear(uuid)

    cartridge_migrators = load_cartridge_migrators 
    output << migrate_env_vars(gear_home)
    output << migrate_cartridges(gear_home, uuid, cartridge_migrators)
    OpenShift::Utils::Sdk.mark_new_sdk_app(gear_home)

    env_echos.each do |env_echo|
      echo_output, echo_exitcode = Util.execute_script(env_echo)
      output += echo_output
    end
      
    start_gear(uuid)

    total_time = (Time.now.to_f * 1000).to_i - start_time
    output += "***time_migrate_on_node_measured_from_node=#{total_time}***\n"
    return output, exitcode
  end

  def self.stop_gear(uuid)
    OpenShift::ApplicationContainer.from_uuid(uuid).stop_gear
  end

  def self.start_gear(uuid)
    OpenShift::ApplicationContainer.from_uuid(uuid).start_gear
  end

  def self.load_cartridge_migrators
    migrators = {}

    cr = OpenShift::CartridgeRepository.instance

    # TODO: fix problems loading commented out lines
    migrators[cr.select('diy', '0.1')] = Diy01Migration.new
    # migrators[cr.select('jbossas', '7')] = Jbossas7Migration.new # name changed to jbossas-7.1
    migrators[cr.select('jbosseap', '6.0')] = Jbosseap60Migration.new
    #migrators[cr.select('jbossews', '1.0')] = Jbossews10Migration.new
    #migrators[cr.select('jbossews', '2.0')] = Jbossews20Migration.new
    migrators[cr.select('nodejs', '0.6')] = Nodejs06Migration.new
    migrators[cr.select('perl', '5.10')] = Perl510Migration.new
    migrators[cr.select('php', '5.3')] = Php53Migration.new
    migrators[cr.select('python', '2.6')] = Python26Migration.new
    migrators[cr.select('ruby', '1.8')] = Ruby18Migration.new
    migrators[cr.select('ruby', '1.9')] = Ruby19Migration.new
    #migrators[cr.select('zend', '5.6')] = Zend56Migration.new # not in li yet
    migrators[cr.select('metrics', '0.1')] = Metrics01Migration.new
    migrators[cr.select('jenkins', '1.4')] = Jenkins14Migration.new
    migrators[cr.select('jenkins-client', '1.4')] = JenkinsClient14Migration.new
    migrators[cr.select('mongodb', '2.2')] = Mongodb22Migration.new
    migrators[cr.select('rockmongo', '1.1')] = Rockmongo11Migration.new
    migrators[cr.select('10gen-mms-agent', '0.1')] = Tengenmmsagent01Migration.new
    migrators[cr.select('mysql', '5.1')] = Mysql51Migration.new
    migrators[cr.select('phpmyadmin', '3.4')] = Phpmyadmin34Migration.new
    migrators[cr.select('postgresql', '8.4')] = Postgresql84Migration.new

    migrators
  end

  def self.migrate_env_vars(gear_home)
    output = ''

    FileUtils.rm_rf(File.join(gear_home, '.env', 'USER_VARS'))
    output << migrate_typeless_translated_vars(gear_home)
    output << migrate_translate_gear_vars(gear_home)
    
    output
  end

  def self.migrate_typeless_translated_vars(gear_home)
    # TODO: split out typeless translated vars into separate files
    ''
  end

  def self.migrate_translate_gear_vars(gear_home)
    # TODO: split out translate gear vars into separate files
    ''
  end

  def self.migrate_cartridges(gear_home, uuid, cartridge_migrators)
    output = ''

    # TODO: establish migration order of cartridges
    v1_cartridges(gear_home).each do |cartridge_name|
      tokens = cartridge_name.split('-')
      name = tokens[0]
      version = tokens[1]
      output << migrate_cartridge(name, version, uuid, true, cartridge_migrators)
    end

    output
  end

  def self.v1_cartridges(gear_home)
    v1_carts = []

    Dir.glob(File.join(gear_home, '*-*')).each do |entry|
      # Account for app-root and V2 carts matching the glob which already may be installed
      next if entry.end_with?('app-root') || entry.end_with?('jenkins-client') || entry.end_with?('mms-agent') || !File.directory?(entry)
        
      v1_carts << File.basename(entry)
    end

    v1_carts
  end

  def self.migrate_cartridge(name, version, uuid, start, cartridge_migrators)
    # TODO: account for 'configure' workflow changes to introduce discrete install and
    # post-setup control actions
    # TODO: migration resume strategy

    config = OpenShift::Config.new
    state = OpenShift::Utils::ApplicationState.new(uuid)
    user = OpenShift::UnixUser.from_uuid(uuid)

    cart_model = OpenShift::V2MigrationCartridgeModel.new(config, user, state)

    output = ''

    cartridge = OpenShift::CartridgeRepository.instance.select(name, version)

    OpenShift::Utils::Cgroups.with_cgroups_disabled(uuid) do
      cart_model.create_cartridge_directory(cartridge, version)
      # total hack because I haven't written the php migration yet.
      #cart_model.create_private_endpoints(cartridge) if name == 'php'

      Dir.chdir(user.homedir) do
        cart_model.unlock_gear(cartridge) do |c|
          output << cart_model.cartridge_action(c, 'setup', version, true)

          cart_model.process_erb_templates(c.directory)

          output << migration_post_process_hook(user, c, cartridge_migrators)
        end
      end

      if start
        output << cart_model.start_cartridge('start', cartridge)
      end

      cart_model.connect_frontend(cartridge)
    end

    FileUtils.rm_rf(File.join(user.homedir, "#{name}-#{version}"))

    output
  end

  def self.migration_post_process_hook(user, cartridge, cartridge_migrators)
    output = ''
    cartridge_migrator = cartridge_migrators[cartridge]

    if cartridge_migrator
      output << cartridge_migrator.post_process(user)
    else
      output << "Unable to find migrator for #{cartridge}\n"
    end

    output
  end
end


