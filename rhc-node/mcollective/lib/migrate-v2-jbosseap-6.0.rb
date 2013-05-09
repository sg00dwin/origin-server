module OpenShiftMigration
  class Jbosseap60Migration
    def post_process(user)
      output = "applying jbosseap-6.0 migration post-process\n"

      Util.mv_env_var_value(user.homedir, 'OPENSHIFT_JBOSSEAP_PORT', 'OPENSHIFT_JBOSSEAP_HTTP_PORT')
            
      cartridge_dir = File.join(user.homedir, 'jbosseap')
            
      modules_jar = File.join(cartridge_dir, 'jboss-modules.jar')
      modules_dir = File.join(cartridge_dir, 'modules')
            
      FileUtils.ln_s('/etc/alternatives/jbosseap-6.0/jboss-modules.jar', modules_jar)
      FileUtils.ln_s('/etc/alternatives/jbosseap-6.0/modules', modules_dir)
        
      Util.make_user_owned(modules_jar, user)
      Util.make_user_owned(modules_dir, user)

      output
    end
  end
end
