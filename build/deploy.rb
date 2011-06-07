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
    rm_rf "#{tmpname}/site/log"
    rm_rf "#{tmpname}/broker/log"
    rm_rf "#{tmpname}/node/tools"    
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
    sh "ssh -i ~/.ssh/libra.pem root@verifier \"cd #{remote_dir}; gunzip li.tar.gz; tar -xf li.tar; cp -R li/node/scripts/bin/* /usr/bin;cp -R li/node/cartridges/* /usr/libexec/li/cartridges; cp -R li/cartridges/* /usr/libexec/li/cartridges; chmod -R 755 /usr/libexec/li/cartridges; cp -R li/node/mcollective/* /usr/libexec/mcollective; cp li/node/facter/libra.rb /usr/lib/ruby/site_ruby/1.8/facter/libra.rb; cp -r li/server-common/* /usr/lib/ruby/site_ruby/1.8/; mv libra/site/httpd site_httpd; mv libra/broker/httpd broker_httpd; rm -rf libra/*; mv li/site libra/site; mv li/broker libra/broker; mv site_httpd libra/site/httpd; mkdir -p libra/site/tmp; mkdir -p libra/site/log; mkdir -p libra/broker/tmp; mkdir -p libra/broker/log; chmod -R 755 libra/; chown root:libra_user -R libra/; touch libra/site/log/development.log; touch libra/site/log/production.log; chmod 0666 libra/site/log/*.log; chmod 755 libra/site/Gemfile.lock; service libra-site restart; mv broker_httpd libra/broker/httpd; touch libra/broker/log/development.log; touch libra/broker/log/production.log; chmod 0666 libra/broker/log/*.log; service libra-broker restart; rm -rf li; rm li.tar\""
    rm "/tmp/li.tar.gz"
  end

  desc "Deploy client (run with sudo)"
  task :client do
    cd CLIENT_ROOT
    cp_r "bin/.", Dir.glob("/usr/lib/ruby/gems/1.8/gems/rhc-*/bin")[0]
    cp_r "lib/.", Dir.glob("/usr/lib/ruby/gems/1.8/gems/rhc-*/lib")[0]
  end

end
