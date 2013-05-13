module OpenShiftMigration
	require 'fileutils'

  class Ruby18Migration
  	RUBY_VERSION='1.8'
    def post_process(user, progress, env)
      output = "applying ruby-#{RUBY_VERSION} migration post-process\n"

      ruby_dir = File.join(user.homedir, 'ruby')

      env_vars = [
      	'OPENSHIFT_RUBY_IP',
      	'OPENSHIFT_RUBY_LOG_DIR',
      	'OPENSHIFT_RUBY_PORT',
      	'LD_LIBRARY_PATH',
      	'MANPATH'
      ]

      output << Util.move_gear_env_var_to_cart(user, 'ruby', env_vars)

      cart_dir = File.join(user.homedir, 'ruby')
      cart_env = File.join(cart_dir, 'env')

      FileUtils.mkdir_p File.join(ruby_dir, 'template')

      Dir.chdir File.join(ruby_dir, 'template') do
      	FileUtils.cp_r File.join(ruby_dir, 'versions', RUBY_VERSION, 'template'), ruby_dir
      end

     	Util.add_cart_env_var(user, 'ruby', 'OPENSHIFT_RUBY_VERSION', RUBY_VERSION)

			Util.make_user_owned(cart_env, user)

      FileUtils.ln_sf '/usr/lib64/httpd/modules', File.join(ruby_dir, 'modules')
      FileUtils.ln_sf '/etc/httpd/conf/magic', File.join(ruby_dir, 'etc', 'magic')

      output
    end
  end
end
