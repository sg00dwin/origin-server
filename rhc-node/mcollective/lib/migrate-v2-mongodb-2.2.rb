module OpenShiftMigration
  class Mongodb22Migration
    def post_process(user, progress, env)
      output = "applying mongodb-2.2 migration post-process\n"
      
      Util.rm_env_var(user.homedir, 'OPENSHIFT_MONGODB_DB_LOG_DIR')
      
      env_vars = %w(USERNAME PASSWORD URL)
      env_vars.map! { |x| "OPENSHIFT_MONGODB_DB_#{x}" }

      output << Util.move_gear_env_var_to_cart(user, 'mongodb', env_vars)
      cart_dir = File.join(user.homedir, 'mongodb')
      cart_env = File.join(cart_dir, 'env')
      Util.make_user_owned(cart_env, user)
      
      directories = %w(log data)
      output << Util.move_directory_between_carts(user, 'mongodb-2.2', 'mongodb', directories)

      output
    end
  end
end