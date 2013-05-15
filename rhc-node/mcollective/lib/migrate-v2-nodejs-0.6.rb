module OpenShiftMigration
  class Nodejs06Migration
    NODEJS_VERSION = '0.6'

    def post_process(user, progress, env)
      output = "applying nodejs-0.6 migration post-process\n"

      nodejs_dir = File.join(user.homedir, 'nodejs')

      Util.rm_env_var(user.homedir, 'OPENSHIFT_NODEJS_LOG_DIR')

      ### npm modules manipulation
      modules = []
      File.open(File.join(nodejs_dir, 'versions', NODEJS_VERSION, 'configuration', 'npm_global_module_list')) do |f|
      	modules = f.readlines.select do |line|
      		line =~ /^\s*[^#\s]/
      	end
      end

      %x(npm link #{modules.map(&:chomp).join(' ')})
      node_modules_dir = File.join(user.homedir, 'node_modules')
      FileUtils.mv node_modules_dir, File.join(user.homedir, '.node_modules')

			%x(touch #{File.join(user.homedir, '.npmrc')})
			FileUtils.mkdir_p(File.join(user.homedir, '.npm'))
			FileUtils.mkdir_p(File.join(user.homedir, '.node-gyp'))
			['.npm', '.npmrc', '.node-gyp'].each do |dir|
				Util.make_user_owned File.join(user.homedir, dir), user
			end

			%x(npm config set tmp #{env['OPENSHIFT_TMP_DIR']})

      output
    end
  end
end