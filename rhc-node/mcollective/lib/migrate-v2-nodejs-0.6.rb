module OpenShiftMigration
  class Nodejs06Migration
    NODEJS_VERSION = '0.6'

    def post_process(user, progress, env)
      output = "applying nodejs-0.6 migration post-process\n"

      nodejs_dir = File.join(user.homedir, 'nodejs')

      Util.rm_env_var(user.homedir, 'OPENSHIFT_NODEJS_LOG_DIR')

      ['.npm', '.npmrc', '.node-gyp'].each do |dir|
        Util.make_user_owned File.join(user.homedir, dir), user
      end

      Util.cp_env_var_value(user.homedir, 'OPENSHIFT_INTERNAL_IP',   'OPENSHIFT_NODEJS_IP')
      Util.cp_env_var_value(user.homedir, 'OPENSHIFT_INTERNAL_PORT', 'OPENSHIFT_NODEJS_PORT')

      output
    end
  end
end
