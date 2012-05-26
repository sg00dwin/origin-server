require 'rubygems'
require 'etc'
require 'fileutils'
require 'socket'
require 'parseconfig'
require 'pp'
require File.dirname(__FILE__) + "/migrate-util"

REMOVE_GEAR_RUNTIME_DIR = false

module OpenShiftMigration

  def self.get_config_value(key)
    @node_config ||= ParseConfig.new('/etc/stickshift/stickshift-node.conf')
    val = @node_config.get_value(key)
    val.gsub!(/\\:/,":") if not val.nil?
    val.gsub!(/[ \t]*#[^\n]*/,"") if not val.nil?
    val = val[1..-2] if not val.nil? and val.start_with? "\""
    val
  end

  def self.get_mcs_level(uuid)
    userinfo = Etc.getpwnam(uuid)
    uid = userinfo.uid
    setsize=1023
    tier=setsize
    ord=uid
    while ord > tier
      ord -= tier
      tier -= 1
    end
    tier = setsize - tier
    "s0:c#{tier},c#{ord + tier}"
  end

  def self.secure_user_files(uuid, grp, perms, mcs_level, pathlist)
    FileUtils.chown_R uuid, grp, pathlist
    FileUtils.chmod_R perms, pathlist
    %x[ chcon -t libra_var_lib_t -l #{mcs_level} -R #{pathlist.join " "} ]
  end

  def self.remove_dir_if_empty(dirname)
    Dir.rmdir dirname if (File.directory? dirname)  &&  (Dir.entries(dirname) - %w[ . .. ]).empty?
  end

  def self.move_dir_and_symlink(srcdir, destdir, symlink_offset=nil)
    if (not File.symlink? srcdir)  &&  (File.directory? srcdir)
      FileUtils.rm_f destdir  if (File.symlink? destdir)  ||  (not File.directory? destdir)
      FileUtils.mkdir_p destdir
      Dir.entries(srcdir).each {|f| FileUtils.mv(File.join(srcdir, f), destdir) unless f == '.' || f == '..'}
      FileUtils.rm_rf srcdir
    end

    FileUtils.rm_f srcdir
    if symlink_offset
      FileUtils.ln_sf symlink_offset, srcdir
    else
      FileUtils.ln_sf destdir, srcdir
    end
  end

  def self.migrate_to_appdir(uuid, gear_home)
    zpathlist = []
    grp = uuid
    mcs_level = self.get_mcs_level(uuid)

    gear_name = Util.get_env_var_value(gear_home, "OPENSHIFT_GEAR_NAME")
    app_name = Util.get_env_var_value(gear_home, "OPENSHIFT_APP_NAME")
    gear_dir = File.join(gear_home, gear_name)
    app_dir = File.join(gear_home, "app")

    FileUtils.mkdir_p app_dir
    zpathlist.push app_dir

    data_dir = File.join(gear_home, gear_name, "data")
    app_data_dir = File.join(app_dir, "data")
    zoffset = File.join("..", "app", "data")
    self.move_dir_and_symlink(data_dir, app_data_dir, zoffset)
    Util.set_env_var_value(gear_home, "OPENSHIFT_DATA_DIR", app_data_dir)
    zpathlist.push app_data_dir

    # Needed until quickstarts refactored to not use relative directories
    FileUtils.ln_s 'app/data', File.join(gear_home, 'data'), :verbose => true

    state_file = File.join(gear_home, gear_name, "runtime", ".state")
    app_state_file = File.join(app_dir, ".state")

    if File.exists? state_file
      FileUtils.mv state_file, app_state_file, :force => true
      zpathlist.push app_state_file
    end

    #  Move the old repo to the new location and create symlinks
    #  for compatibility to existing apps.
    old_runtime_dir = File.join(gear_home, gear_name, "runtime")
    if File.exists? old_runtime_dir
      old_runtime_repo_dir = File.join(old_runtime_dir, "repo")
      app_repo_dir = File.join(app_dir, "repo")
      self.move_dir_and_symlink(old_runtime_repo_dir, app_repo_dir)
      if REMOVE_GEAR_RUNTIME_DIR
        FileUtils.rm_f old_runtime_repo_dir
        self.remove_dir_if_empty(old_runtime_dir)
      else
        # If we want to keep the old runtime dir around.
        zpathlist.push old_runtime_repo_dir
      end
      Util.set_env_var_value(gear_home, "OPENSHIFT_REPO_DIR", app_repo_dir)
    end

    gear_repo_dir = File.join(gear_home, gear_name, "repo")
    if (gear_name != app_name)  &&  (File.symlink? gear_repo_dir)
      zoffset = File.join("..", "app", "repo")
      FileUtils.rm_f gear_repo_dir
      FileUtils.ln_sf zoffset, gear_repo_dir
      zpathlist.push gear_repo_dir
    end

    gear_type = Util.get_env_var_value(gear_home, "OPENSHIFT_GEAR_TYPE")
    cart_dir = File.join(gear_home, gear_type)
    if gear_type == "mysql-5.1"
      gnamedir = File.join(gear_home, gear_name)
      if not File.symlink? gnamedir
        FileUtils.mv File.join(gnamedir, "ci"), cart_dir, :verbose => true
        FileUtils.mv File.join(gnamedir, gear_name + "_ctl.sh"),
                               File.join(cart_dir), :verbose => true
        FileUtils.rm_rf gnamedir
        FileUtils.ln_sf gear_type, gnamedir
      end
      zpathlist.pop if zpathlist.include? gear_repo_dir
    else
      self.move_dir_and_symlink(File.join(gear_home, gear_name), cart_dir,
                                gear_type)
    end 

    self.secure_user_files(uuid, grp, 0750, mcs_level, zpathlist)
  end

  # 1) Save/Destroy current proxy configuration
  # 2) Deploy new proxy configuration
  def self.migrate_http_proxy(uuid, namespace, version,
                              gear_name, gear_home, gear_type,
                              cartridge_root_dir) 
      output = ''
      http_conf_dir = get_config_value('STICKSHIFT_HTTP_CONF_DIR')
      ip = Util.get_env_var_value(gear_home, "OPENSHIFT_INTERNAL_IP")

      token = "#{uuid}_#{namespace}_#{gear_name}"
      proxy_conf = File.join(http_conf_dir, "#{token}.conf")
      proxy_conf_dir = File.join(http_conf_dir, token)

      target = File.join('/tmp', 'rhc', 'proxy_backups')
      FileUtils.makedirs(target)

      if File.file?(proxy_conf) && File.directory?(proxy_conf_dir)
        # Don't overwrite backup files when migration is re-run
        target = File.join(target, "#{token}.tgz")
        output += `tar zcf #{target} #{proxy_conf} #{proxy_conf_dir}` if not File.exist?(target)

        # Some of this logic stolen from deploy-httpd-proxy
        # deploy-httpd-proxy hook gets confused because we're moving conf files around
        gear_idle = File.exist?(File.join(proxy_conf_dir, '0000000000000_disabled.conf'))

        FileUtils.remove_file(proxy_conf, :verbose => true)
        FileUtils.remove_dir(proxy_conf_dir, :verbose => true)
        FileUtils.makedirs(proxy_conf_dir, :verbose => true)

        deploy_httpd_proxy = File.join(cartridge_root_dir, gear_type,
                                       'info', 'bin', 'deploy_httpd_proxy.sh')
        if not File.exist? deploy_httpd_proxy
          deploy_httpd_proxy = File.join(cartridge_root_dir, 'abstract',
                                         'info', 'bin', 'deploy_httpd_proxy.sh')
        end

        ENV['CART_INFO_DIR'] = File.join(cartridge_root_dir, gear_type, 'info')
        output += `#{deploy_httpd_proxy} #{gear_name} #{namespace} #{uuid} #{ip} 2>&1`

        `rhc-idler -u #{uuid}` if gear_idle

        output += "Proxy redeploy for #{token} complete\n"
      else
        output += "Proxy configuration for #{token} not as expected.\n"
        output += "- #{proxy_conf}.file?(#{File.file?(proxy_conf)})\n"
        output += "- #{proxy_conf_dir}.directory?(#{File.directory?(proxy_conf_dir)})\n"
      end
      return output
  end

  def self.fix_dbhost_for_scaleable_apps(gear_home)
    output = ""
    dbhost_file = File.join(gear_home, ".env", ".uservars", "OPENSHIFT_DB_HOST")
    dbgeardns_file = File.join(gear_home, ".env", ".uservars",
                                 "OPENSHIFT_DB_GEAR_DNS")
    if File.exists? dbgeardns_file
      db_gear_dns = Util.file_to_string(dbgeardns_file).strip
      if db_gear_dns.length > 0
        dbhost = Util.file_to_string(dbhost_file).strip
        Util.replace_in_file(dbhost_file, dbhost, db_gear_dns)
        output += "Updated OPENSHIFT_DB_HOST to '#{db_gear_dns}'\n"
      else
        output += "!Warning! OPENSHIFT_DB_GEAR_DNS empty value for gear #{gear_home}"
      end
    end
    return output
  end

  def self.migrate(uuid, namespace, version)
    if version == "2.0.12"
      libra_home = '/var/lib/stickshift' #node_config.get_value('libra_dir')
      libra_server = get_config_value('BROKER_HOST')
      libra_domain = get_config_value('CLOUD_DOMAIN')
      gear_home = "#{libra_home}/#{uuid}"
      gear_name = Util.get_env_var_value(gear_home, "OPENSHIFT_GEAR_NAME")
      gear_dir = "#{gear_home}/#{gear_name}"
      output = ''
      exitcode = 0

      if (File.exists?(gear_home) && !File.symlink?(gear_home))
        gear_type = Util.get_env_var_value(gear_home, "OPENSHIFT_GEAR_TYPE")
        cartridge_root_dir = "/usr/libexec/stickshift/cartridges"
        cartridge_dir = "#{cartridge_root_dir}/#{gear_type}"

        env_echos = []

        begin
          output += self.migrate_http_proxy(uuid, namespace, version,
                                            gear_name, gear_home, gear_type,
                                            cartridge_root_dir)
        rescue => e
          output += "\n#{e.message}\n#{e.backtrace}\n"
        end

        self.migrate_to_appdir(uuid, gear_home)

        # Fix up incorrect DB_HOST setting for mysql added to scalable apps.
        output += self.fix_dbhost_for_scaleable_apps(gear_home)

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
end
