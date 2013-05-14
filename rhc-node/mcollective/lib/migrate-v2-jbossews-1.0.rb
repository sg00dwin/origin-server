require_relative 'migrate-util'

module OpenShiftMigration
  class Jbossews10Migration
    def post_process(user, progress, env)
      output = "applying jbossews-1.0 migration post-process\n"

      cart_name = 'jbossews'
      cart_dir = File.join(user.homedir, cart_name)

      # Prune old variables
      Util.rm_env_var(user.homedir, 'OPENSHIFT_JBOSSEWS_LOG_DIR', 'PATH')

      # Hang on to these, we'll need them later...
      java_home = Util.get_env_var_value(user.homedir, 'JAVA_HOME')
      m2_home = Util.get_env_var_value(user.homedir, 'M2_HOME')

      # Move vars from the gear to the cart
      Util.move_gear_env_var_to_cart(user, cart_name, ['JAVA_HOME', 'M2_HOME', 'OPENSHIFT_JBOSSEWS_PORT'])

      # Deal with renamed variables
      Util.cp_env_var_value(user.homedir, 'OPENSHIFT_INTERNAL_IP', 'OPENSHIFT_JBOSSEWS_IP')
      Util.cp_env_var_value(user.homedir, 'OPENSHIFT_INTERNAL_PORT', 'OPENSHIFT_JBOSSEWS_HTTP_PORT')
      Util.add_gear_env_var(user, 'OPENSHIFT_JBOSSEWS_JPDA_PORT', '8787')
      Util.mv_env_var_value(user, 'OPENSHIFT_JBOSSEWS_PROXY_PORT', 'OPENSHIFT_JBOSSEWS_HTTP_PROXY_PORT')

      # Reconstruct PATH (normally happens during v2 install)
      Util.add_cart_env_var(user, cart_name, 'OPENSHIFT_JBOSSEWS_PATH_ELEMENT', "#{java_home}/bin:#{m2_home}/bin")

      # Re-establish webapps symlink (normally happens during v2 install)
      FileUtils.ln_s(File.join(user.homedir, 'app-root', 'repo', 'webapps'), File.join(cart_dir, 'webapps'))
      
      # Replace a couple of v2 links with physical files as the old apps didn't contain these files
      ['catalina.policy', 'postgresql_module.xml'].each do |conf|
        FileUtils.rm_f(File.join(cart_dir, 'conf', conf))
        FileUtils.cp(File.join(cart_dir, 'versions', 'shared', 'configuration', conf), File.join(cart_dir, 'conf', conf))
      end

      # Link the old nested jbossews-1.0 cart subdirectory to the gear level directory
      FileUtils.ln_s(cart_dir, File.join(cart_dir, 'jbossews-1.0'))

      output
    end
  end
end
