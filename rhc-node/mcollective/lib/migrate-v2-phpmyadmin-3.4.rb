module OpenShiftMigration
  class Phpmyadmin34Migration
    def post_process(user, progress, env)
      output = "applying phpmyadmin-3.4 migration post-process\n"
      
      Util.rm_env_var(user.homedir, 'OPENSHIFT_PHPMYADMIN_LOG_DIR')
      
      cartridge_dir = File.join(user.homedir, 'phpmyadmin')
      
      FileUtils.ln_sf('/usr/lib64/httpd/modules', File.join(cartridge_dir, 'modules'))
      FileUtils.ln_sf('/etc/httpd/conf/magic', File.join(cartridge_dir, 'conf', 'magic'))
        
      directories = %w(logs sessions)
      output << Util.move_directory_between_carts(user, 'phpmyadmin-3.4', 'phpmyadmin', directories)

      Util.cp_env_var_value(user.homedir, 'OPENSHIFT_INTERNAL_IP',   'OPENSHIFT_PHPMYADMIN_IP')
      Util.cp_env_var_value(user.homedir, 'OPENSHIFT_INTERNAL_PORT', 'OPENSHIFT_PHPMYADMIN_PORT')

      output
    end
  end
end
