namespace :rpm do
  task :gem do
    puts "Building client gem..."
    cd CLIENT_ROOT
    sh "rake", "package"
    cd ".."
    puts "Done"
  end

  desc "Mash rhel-6-libra-candidate repo from brew"
  task :mash do
      if !File.exists?("/etc/mash/libra-rhel-6.1-candidate.mash")
          puts
          puts "Please install and configure mash.  Read misc/BREW for setup steps"
          puts
          exit 222
      end

      # Make sure we have write access to /var/cache/mash
      begin
        File.new("/var/cache/mash/.rhcignore", "w")
        File.delete("/var/cache/mash/.rhcignore")
      rescue Errno::EACCES
        puts "ERROR - user doesn't have write access to /var/cache/mash"
        exit 1
      end

      # Run mash twice since it usually fails the first time
      `/usr/bin/mash -o /tmp/libra-rhel-6.1-candidate -c /etc/mash/li-mash.conf libra-rhel-6.1-candidate`

      # This time, use 'sh' to fail the build if it fails
      sh "/usr/bin/mash -o /tmp/libra-rhel-6.1-candidate -c /etc/mash/li-mash.conf libra-rhel-6.1-candidate"
  end

  task :sync do
    puts "Syncing RPMs and gems to repo..."
    sh "rsync -avz -e ssh /tmp/libra-rhel-6.1-candidate/libra-rhel-6.1-candidate/* root@dhcp1:/srv/web/gpxe/trees/rhel-6-libra-candidate/"
    sh "rsync -avz -e ssh client/pkg/* root@dhcp1:/srv/web/gpxe/trees/client/gems/"
    puts "Done"

    puts "Updating gem indexes..."
    sh "ssh dhcp1 'gem generate_index -d /srv/web/gpxe/trees/client'"
    puts "Done"

    puts "Kicking off AMI build..."
    sh "curl --insecure --proxy squid.corp.redhat.com:8080 https://ci.dev.openshift.redhat.com/jenkins/job/libra_ami/build?token=libra1"
    puts "Done"
  end
  
  task :release => [:gem, :mash, :sync]
end
