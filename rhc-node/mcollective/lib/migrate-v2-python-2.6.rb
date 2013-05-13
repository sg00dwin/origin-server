module OpenShiftMigration
  class Python26Migration
    def post_process(user, progress, env)
      output = "applying python-2.6 migration post-process\n"


      Util.rm_env_var(user.homedir, 'OPENSHIFT_PYTHON_LOG_DIR')

      cartridge_dir = File.join(user.homedir, 'python')

      FileUtils.ln_sf('/usr/lib64/httpd/modules', cartridge_dir)
      FileUtils.ln_sf('/etc/httpd/conf/magic', File.join(cartridge_dir, 'etc', 'magic'))

      Util.add_cart_env_var(user, 'python', 'OPENSHIFT_PYTHON_VERSION', '2.6')
      FileUtils.mkpath(File.join(cartridge_dir, 'virtenv'))

      directories = %w(logs virtenv)
      output << Util.move_directory_between_carts(user, 'python-2.6', 'python', directories)

      output
    end
  end
end
