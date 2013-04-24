require_relative 'migrate-util'

module OpenShiftMigration
  class Php53Migration
    def post_process(user)
      output = "applying php-5.3 migration post-process\n"

      Util.rm_env_var(user.homedir, 'OPENSHIFT_PHP_LOG_DIR')
      
      output
    end
  end
end