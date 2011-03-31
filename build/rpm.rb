namespace :rpm do
  task :version do
      @version = RPM_REGEX.match(File.read(RPM_SPEC))[2]
      puts "Current Version is #{@version}"
  end

  task :buildroot do
      # Get the RPM build root for the system
      @buildroot = `rpm --eval "%{_topdir}"`.chomp!
      puts "Build root is #{@buildroot}"
  end

  task :commit_check do
      # Get the current spec version
      # Make sure everything is committed - otherwise exit
      sh("git diff-index --quiet #{TARGET_BRANCH}") do |ok, res|
        if !ok
          puts "ERROR - Uncommitted repository changes"
          puts "Checkin / revert before continuing."
          exit 1
        end
      end
  end

  desc "Build the Libra SRPM"
  task :srpm => [:version, :buildroot, :commit_check] do
      # Archive the git repository and compress it for the SOURCES
      src = "#{@buildroot}/SOURCES/li-#{@version}.tar"
      sh "git archive --prefix=li-#{@version}/ #{TARGET_BRANCH} --output #{src}"
      sh "gzip -f #{src}"

      # Move the SPEC file out
      cp File.dirname(File.expand_path(__FILE__)) + "/specs/li.spec", "#{@buildroot}/SPECS"

      # Build the source RPM
      sh "rpmbuild -bs #{@buildroot}/SPECS/li.spec"
  end

  task :bump_release => [:version, :commit_check] do
      # Bump the version number
      @version = @version.succ
      puts "New Version number is #{@version}"

      # Get the RPM version and reset the release number to 1
      replace = File.read(RPM_SPEC).gsub(RPM_REGEX, "\\1#{@version}")
      replace = replace.gsub(RPM_REL_REGEX, "\\1" + "1" + "\\3")

      # Add a comment to the RPM log
      comment = "* " + Time.now.strftime("%a %b %d %Y")
      comment << " " + `git config --get user.name`.chomp
      comment << " <" + `git config --get user.email`.chomp + ">"
      comment << " " + @version + "-1"
      comment << "\n- Upstream released new version\n"
      replace = replace.gsub(/(%changelog.*)/, "\\1\n#{comment}")

      # Write out and commit the new spec file
      File.open(RPM_SPEC, "w") {|file| file.puts replace}
      sh "git commit -a -m 'Upstream released new version'"
  end

  desc "Increment release number and build Libra RPMs"
  task :release => [:bump_release, :rpm]

  desc "Create a brew build based on current info"
  task :brew => [:version, :buildroot, :srpm] do
      srpm = Dir.glob("#{@buildroot}/SRPMS/li-#{@version}*.rpm")[0]
      if ! File.exists?("#{ENV['HOME']}/cvs/li/RHEL-6-LIBRA")
          puts "Please check out the li cvs root:"
          puts
          puts "mkdir -p #{ENV['HOME']}/cvs; cd #{ENV['HOME']}/cvs"
          puts "cvs -d :gserver:cvs.devel.redhat.com:/cvs/dist co li"
          exit 206
      end
      cp "build/specs/li.spec", "#{ENV['HOME']}/cvs/li/RHEL-6-LIBRA"
      cd "#{ENV['HOME']}/cvs/li/RHEL-6-LIBRA"
      sh "cvs up -d"
      sh "make new-source FILES='#{@buildroot}/SOURCES/li-#{@version}.tar.gz'"
      sh "cvs commit -m 'Updating to most recent li build #{@version}'"
      sh "make tag"
      sh "make build"
  end

  desc "Mash rhel-6-libra-candidate repo from brew"
  task :mash-candidate do
      if ! File.exists?("/etc/mash/li.mash")
          puts
          puts "Please install and configure mash.  Read misc/BREW for setup steps"
          puts
          exit 222
      end
      sh "/usr/bin/mash -o /tmp/rhel-6-libra-candidate -c /etc/mash/li-mash.conf rhel-6-libra-candidate"
  end

  desc "Mash rhel-6-libra repo from brew"
  task :mash-candidate do
      if ! File.exists?("/etc/mash/li.mash")
          puts
          puts "Please install and configure mash.  Read misc/BREW for setup steps"
          puts
          exit 222
      end
      sh "/usr/bin/mash -o /tmp/rhel-6-libra -c /etc/mash/li-mash.conf rhel-6-libra"
  end

end
