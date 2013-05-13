module OpenShiftMigration
  class Diy01Migration
    def post_process(user, progress, env)
      output = "applying diy-0.1 migration post-process\n"

      Util.rm_env_var(user.homedir, 'OPENSHIFT_DIY_LOG_DIR')

      cart_dir = File.join(user.homedir, 'diy')

      directories = %w(logs)
      output << Util.move_directory_between_carts(user, 'diy-0.1', 'diy', directories)

      output
    end
  end
end