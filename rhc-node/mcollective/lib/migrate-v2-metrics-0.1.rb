module OpenShiftMigration
  class Metrics01Migration
    def post_process(user, progress, env)
      output = "applying metrics-0.1 migration post-process\n"
      
      Util.rm_env_var(user.homedir, 'OPENSHIFT_METRICS_LOG_DIR')

      cartridge_dir = File.join(user.homedir, 'metrics')
      
      FileUtils.ln_sf('/usr/lib64/httpd/modules', File.join(cartridge_dir, 'modules'))
      FileUtils.ln_sf('/etc/httpd/conf/magic', File.join(cartridge_dir, 'conf', 'magic'))
        
      directories = %w(logs sessions)
      output << Util.move_directory_between_carts(user, 'metrics-0.1', 'metrics', directories)

      output
    end
  end
end
