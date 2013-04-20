require 'openshift-origin-node/utils/selinux'
require 'openshift-origin-node/utils/path_utils'

module OpenShiftMigration
  class Mysql51Migration
    def post_process(user)
      # TODO: determine whether owner/selinux context needs to change
      FileUtils.rm_rf(File.join(user.homedir, 'app-root', 'data', '.mysql_setup_invocation_marker'))

      output = "applying mysql-5.1 migration post-process:\n"
      output << `ls -l /var/lib/openshift/#{user.uuid}/.env`

      FileUtils.rm_rf(File.join(user.homedir, '.env', 'OPENSHIFT_MYSQL_DB_SOCKET'))
      FileUtils.rm_rf(File.join(user.homedir, '.env', 'OPENSHIFT_MYSQL_DB_LOG_DIR'))

      gear_env = File.join(user.homedir, '.env')
      cart_env = File.join(user.homedir, 'mysql', 'env')

      env_vars = %w(USERNAME PASSWORD URL LOG_DIR)
      env_vars.each do |var|
        env_var_name = "OPENSHIFT_MYSQL_DB_#{var}"
        gear_env_var = File.join(gear_env, env_var_name)

        next if !File.exists?(gear_env_var)

        cart_env_var = File.join(cart_env, env_var_name)

        output << "Moving env var #{env_var_name} to cartridge env var directory\n"

        FileUtils.mv(gear_env_var, cart_env_var)
      end

      set_ownership(cart_env, user)

      directories = %w(log data)
      directories.each do |directory|
        next if !File.directory?(File.join(user.homedir, 'mysql-5.1', directory))

        output << "Moving contents of mysql-5.1/#{directory} to mysql/#{directory}\n"
        target_directory = File.join(user.homedir, 'mysql', directory)

        Dir.glob(File.join(user.homedir, 'mysql-5.1', directory, '*')).each do |entry|
          target = File.join(target_directory, File.basename(entry))
          FileUtils.mv(entry, target, force: true)
        end

        set_ownership(target_directory, user)
      end

      output
    end

    def set_ownership(target, user)
      mcs_label = OpenShift::Utils::SELinux.get_mcs_label(user.uid)
      PathUtils.oo_chown_R(user.uid, user.gid, target)
      OpenShift::Utils::SELinux.set_mcs_label_R(mcs_label, target)
    end
  end
end