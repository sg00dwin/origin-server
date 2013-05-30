module OpenShiftMigration
  class Switchyard06Migration
    def post_process(user, progress, env)
      output = "applying switchyard-0.6 migration post-process\n"

      Util.rm_env_var(user.homedir, 'OPENSHIFT_JBOSSAS_MODULE_PATH')
      Util.rm_env_var(user.homedir, 'OPENSHIFT_JBOSSEAP_MODULE_PATH')

      output
    end
  end
end