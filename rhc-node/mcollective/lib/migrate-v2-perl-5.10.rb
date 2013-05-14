module OpenShiftMigration
  class Perl510Migration
    def post_process(user, progress, env)
      output = "applying perl-5.10 migration post-process\n"

      Util.rm_env_var(user.homedir, 'OPENSHIFT_PERL_LOG_DIR')

      perl_dir = File.join(user.homedir, 'perl')
      ln_if_missing('/usr/lib64/httpd/modules', File.join(perl_dir, 'modules'))
      ln_if_missing('/etc/httpd/conf/magic', File.join(perl_dir, 'etc', 'magic'))

      directories = %w(logs perl5lib)
      output << Util.move_directory_between_carts(user, 'perl-5.10', 'perl', directories)

      output
    end

    def ln_if_missing(source, target)
      FileUtils.ln_s(source, target) unless File.exists? target
    end
  end
end