require_relative 'migrate-util'

module OpenShiftMigration
  class Postgresql84Migration
    def post_process(user, progress, env)
      output = "applying postgresql-8.4 migration post-process\n"

      Util.rm_env_var(user.homedir, 'OPENSHIFT_POSTGRESQL_DB_SOCKET')
      Util.rm_env_var(user.homedir, 'OPENSHIFT_POSTGRESQL_DB_LOG_DIR')
      Util.rm_env_var(user.homedir, 'OPENSHIFT_POSTGRESQL_DB_PID')

      # Copy username to PGUSER env var
      username = Util.get_env_var_value(user.homedir, 'OPENSHIFT_POSTGRESQL_DB_USERNAME')
      Util.add_cart_env_var(user, 'postgresql', 'PGUSER', username)

      # Move old ENV vars
      env_vars = %w(USERNAME PASSWORD URL SOCKET URL LOG_DIR)
      env_vars.map! { |x| "OPENSHIFT_POSTGRESQL_DB_#{x}" }

      output << Util.move_gear_env_var_to_cart(user, 'postgresql', env_vars)
      cart_dir = PathUtils.join(user.homedir, 'postgresql')
      cart_env = PathUtils.join(cart_dir, 'env')
      Util.make_user_owned(cart_env, user)

      directories = %w(log data)
      output << Util.move_directory_between_carts(user, 'postgresql-8.4', 'postgresql', directories)

      # Apply the correct permissions to these files
      FileUtils.chmod(0700, PathUtils.join(cart_dir,'data'))
      FileUtils.chmod(0700, PathUtils.join(cart_dir,'socket'))
      FileUtils.chmod(0600, PathUtils.join(user.homedir,'.pgpass'))

      conf_dir = PathUtils.join(cart_dir,'conf')

      # Ensure our new conf files are used in the v2 cart
      %w(postgresql.conf pg_hba.conf).each do |file|
        src = PathUtils.join(conf_dir,file)
        # Back up old files in case the user made changes
        "#{src}.bak".tap do |bak|
          # Make sure not to overwrite an existing backup in case we are rerunning
          FileUtils.cp(src, bak) unless File.exists?(bak)
        end
        FileUtils.cp(src, PathUtils.join(cart_dir,'data'))
      end

      FileUtils.cp(PathUtils.join(conf_dir,'psqlrc'),PathUtils.join(user.homedir,'.psqlrc'))

      # Make sure the file exists
      PathUtils.join(user.homedir,'.psql_history').tap do |file|
        FileUtils.mv(file, PathUtils.join(user.homedir,'app-root','data')) if File.exists?(file)
      end

      output
    end
  end
end
