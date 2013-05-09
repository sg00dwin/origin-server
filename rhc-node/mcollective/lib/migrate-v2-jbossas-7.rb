module OpenShiftMigration
  class Jbossas7Migration
    def post_process(user)
      output = "applying jbossas-7 migration post-process\n"

      Util.mv_env_var_value(user.homedir, 'OPENSHIFT_JBOSSAS_PORT', 'OPENSHIFT_JBOSSAS_HTTP_PORT')
      
      cartridge_dir = File.join(user.homedir, 'jbossas')
      
      modules_jar = File.join(cartridge_dir, 'jboss-modules.jar')
      modules_dir = File.join(cartridge_dir, 'modules')
            
      FileUtils.ln_s('/etc/alternatives/jbossas-7/jboss-modules.jar', modules_jar)
      FileUtils.ln_s('/etc/alternatives/jbossas-7/modules', modules_dir)
        
      Util.make_user_owned(modules_jar, user)
      Util.make_user_owned(modules_dir, user)

      output
    end
  end
end
