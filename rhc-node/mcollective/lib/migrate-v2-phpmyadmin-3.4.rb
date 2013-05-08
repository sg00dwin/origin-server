module OpenShiftMigration
  class Phpmyadmin34Migration
    def post_process(user)
      output = "applying phpmyadmin-3.4 migration post-process\n"
      
      Util.rm_env_var(user.homedir, 'OPENSHIFT_PHPMYADMIN_LOG_DIR')
      
      cartridge_dir = File.join(user.homedir, 'phpmyadmin')
      
      FileUtils.ln_s('/usr/lib64/httpd/modules', File.join(cartridge_dir, 'modules'))
      FileUtils.ln_s('/etc/httpd/conf/magic', File.join(cartridge_dir, 'conf', 'magic'))
        
      directories = %w(logs)
      output << Util.move_directory_between_carts(user, 'phpmyadmin-3.4', 'phpmyadmin', directories)

      output
    end
  end
end