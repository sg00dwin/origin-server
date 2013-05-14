module OpenShiftMigration
  class Jenkins14Migration
    def post_process(user, progress, env)
      output = "applying jenkins-1.4 migration post-process\n"

      Util.rm_env_var(user.homedir, 'OPENSHIFT_JENKINS_LOG_DIR')

      cart_dir = File.join(user.homedir, 'jenkins')

      directories = %w(logs)
      output << Util.move_directory_between_carts(user, 'jenkins-1.4', 'jenkins', directories)
      
      output
    end
  end
end