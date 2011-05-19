namespace :deploy do

  desc "Deploy devenv"
  task :devenv do
    cd ROOT
    sh("git diff-index --quiet HEAD") do |ok, res|
      if !ok
        puts "WARNING - Uncommitted repository changes"
      end
    end
    cd ROOT + '/..'

    tmpname = "/tmp/li"
    rm_rf tmpname if File.exists? tmpname 
    if File.symlink? "li"
      sh "cp -RL li #{tmpname}"
    else
      cp_r "li", tmpname
    end
    rm_rf "#{tmpname}/.git"
    rm_rf "#{tmpname}/.gitignore"
    rm_rf "#{tmpname}/client"
    rm_rf "#{tmpname}/docs"
    rm_rf "#{tmpname}/build"
    rm_rf "#{tmpname}/tests"
    rm_rf "#{tmpname}/server/log"
    rm_rf "#{tmpname}/node/tools"    
    rm_rf "#{tmpname}/node/scripts"
    rm_rf "#{tmpname}/node/conf"
    rm_rf "#{tmpname}/node/selinux"
    rm_rf "#{tmpname}/.project"
    rm_rf "#{tmpname}/Rakefile"
    cd "#{tmpname}/.."
    sh "tar -cvf /tmp/li.tar li"
    sh "gzip /tmp/li.tar"
    cd ROOT + '/..'
    rm_rf tmpname
    remote_dir = "/var/www"
    sh "scp -i ~/.ssh/libra.pem /tmp/li.tar.gz verifier:#{remote_dir}"
    sh "ssh -i ~/.ssh/libra.pem root@verifier \"cd #{remote_dir}; gunzip li.tar.gz; tar -xf li.tar; rm -rf /usr/libexec/li/cartridges/*; cp -R li/node/cartridges/* /usr/libexec/li/cartridges; cp -R li/node/mcollective/* /usr/libexec/mcollective/mcollective/agent; cp li/node/facter/libra.rb /usr/lib/ruby/site_ruby/1.8/facter/libra.rb; mv libra/httpd httpd; rm -rf libra; mv li/server libra; mv httpd libra/httpd; mkdir -p libra/tmp; mkdir -p libra/log; touch libra/log/development.log; chmod 0666 libra/log/development.log; touch libra/log/production.log; chmod 0666 libra/log/production.log; chmod 755 libra/Gemfile.lock; service libra-site restart; rm -rf li; rm li.tar\""
    rm "/tmp/li.tar.gz"
  end

  desc "Deploy client (run with sudo)"
  task :client do
    cd CLIENT_ROOT
    cp_r "bin/.", Dir.glob("/usr/lib/ruby/gems/1.8/gems/rhc-*/bin")[0]
    cp_r "lib/.", Dir.glob("/usr/lib/ruby/gems/1.8/gems/rhc-*/lib")[0]
  end

end
