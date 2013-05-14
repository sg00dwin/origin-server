module OpenShiftMigration
  class Haproxy14Migration
    def post_process(user, progress, env)
      output = "applying haproxy-1.4 migration post-process\n"
      Util.rm_env_var(user.homedir, 'OPENSHIFT_HAPROXY_LOG_DIR')
      Util.mv_env_var_value(user, 'OPENSHIFT_HAPROXY_INTERNAL_IP', 'OPENSHIFT_HAPROXY_IP')

      directories = %w(logs conf)
      output << Util.move_directory_between_carts(user, 'haproxy-1.4', 'haproxy', directories)

      Util.add_gear_env_var(user, 'OPENSHIFT_HAPROXY_PORT', '8080')
      Util.add_gear_env_var(user, 'OPENSHIFT_HAPROXY_STATUS_PORT', '8080')
      output
    end
  end
end
