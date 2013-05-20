module OpenShiftMigration
  class Rockmongo11Migration
    def post_process(user, progress, env)
      output = "applying rockmongo-1.1 migration post-process\n"

      Util.rm_env_var(user.homedir, 'OPENSHIFT_ROCKMONGO_LOG_DIR')

      cartridge_dir = File.join(user.homedir, 'rockmongo')

      directories = %w(logs sessions)
      output << Util.move_directory_between_carts(user, 'rockmongo-1.1', 'rockmongo', directories)

      Util.cp_env_var_value(user.homedir, 'OPENSHIFT_INTERNAL_IP',   'OPENSHIFT_ROCKMONGO_IP')
      Util.cp_env_var_value(user.homedir, 'OPENSHIFT_INTERNAL_PORT', 'OPENSHIFT_ROCKMONGO_PORT')

      output
    end
  end
end