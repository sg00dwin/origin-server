module OpenShiftMigration
  class Php53Migration
    def post_process(user)
      output = "applying php-5.3 migration post-process\n"
      FileUtils.rm_rf(File.join(user.homedir, '.env', 'OPENSHIFT_PHP_LOG_DIR'))
      output
    end
  end
end