module OpenShiftMigration
  class Jenkins14Migration
    def post_process(user)
      output = "applying jenkins-1.4 migration post-process\n"

      Util.rm_env_var(user.homedir, 'OPENSHIFT_JENKINS_LOG_DIR')
      output
    end
  end
end