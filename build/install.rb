namespace :install do

  namespace :test do
      task :client do
          cd CLIENT_ROOT
          Dir.glob("rhc*").each{|client_file| sh "ruby", "-c", client_file}
      end

      task :node do
          cd NODE_ROOT
          Dir.glob("**/*.rb").each{|node_file| sh "ruby", "-c", node_file}

          cd "tools"
          sh "rake", "test"
      end

      task :all => [:client, :node]
  end

  task :client do
      cd CLIENT_ROOT

      mkdir_p MAN_DIR + "/man1"
      mkdir_p MAN_DIR + "/man5"
      Dir.glob("man/*").each {|file_name|
          man_section = file_name.to_s.split('').last
          cp file_name, "#{MAN_DIR}/man#{man_section}/"
      }

      mkdir_p CONF_DIR
      cp "conf/libra.conf.sample", CONF_DIR + "/libra.conf" unless File.exists? CONF_DIR + "/libra.conf"

      # Package the gem
      sh "rake", "package"
  end

  task :common do
      cd COMMON_ROOT

      mkdir_p MCOLLECTIVE_CONN_DIR
      cp "mcollective/connector/amqp.rb", MCOLLECTIVE_CONN_DIR
  end

  task :node do
      cd NODE_ROOT

      # MCollective setup
      mkdir_p MCOLLECTIVE_DIR
      cp "mcollective/libra.ddl", MCOLLECTIVE_DIR
      cp "mcollective/libra.rb", MCOLLECTIVE_DIR
      cp "mcollective/update_yaml.pp", "#{MCOLLECTIVE_DIR}/../../"
      mkdir_p FACTER_DIR
      cp "facter/libra.rb", FACTER_DIR

      # Jailing setup
      mkdir_p INITRD_DIR
      cp "scripts/libra", INITRD_DIR
      cp "scripts/libra-data", INITRD_DIR
      cp "scripts/libra-cgroups", INITRD_DIR
      cp "scripts/libra-tc", INITRD_DIR
      mkdir_p BIN_DIR
      cp "scripts/trap-user", BIN_DIR
      cp "scripts/rhc-restorecon", BIN_DIR
      cp "scripts/rhc-init-quota", BIN_DIR
      mkdir_p LIBRA_DIR
      mkdir_p "#{DEST_DIR}/usr/share/selinux/packages"
      cp "selinux/libra.pp", "#{DEST_DIR}/usr/share/selinux/packages"
      cp "selinux/rhc-ip-prep.sh", "#{BIN_DIR}"

      # Apache vhost fix
      mkdir_p "#{HTTP_CONF_DIR}/libra/"
      chmod 0750, "#{HTTP_CONF_DIR}/libra/"
      cp "conf/000000_default.conf", HTTP_CONF_DIR
      chmod 0640, "#{HTTP_CONF_DIR}/000000_default.conf"

      # Cartridge installation
      mkdir_p LIBEXEC_DIR
      cp_r "cartridges", LIBEXEC_DIR
      mkdir_p CONF_DIR
      sample_conf = Dir.glob("cartridges/li-controller*/**/node.conf-sample")[0]
      cp_r sample_conf, "#{CONF_DIR}/node.conf" unless File.exists? "#{CONF_DIR}/node.conf"
      cp "conf/resource_limits.conf", CONF_DIR unless File.exists? "#{CONF_DIR}/resource_limits.conf"

      # Tools installation
      cd "tools"
      sh "rake", "package"
  end

  task :server do
      # Rails app setup
      cd ROOT
      mkdir_p HTML_DIR
      cp_r "server", HTML_DIR + "/libra"

      cd SERVER_ROOT

      # Apache setup
      mkdir_p HTTP_CONF_DIR
      cp "config/rails.conf", HTTP_CONF_DIR

      # Scripts setup
      mkdir_p BIN_DIR
      Dir.glob("script/rhc-*").each do |script|
        cp script, File.join(BIN_DIR, File.basename(script))
      end

      # Config setup
      mkdir_p CONF_DIR
      cp "config/controller.conf", CONF_DIR unless File.exists? "#{CONF_DIR}/controller.conf"
  end

  desc "Install all the Libra files (e.g. rake DESTDIR='/tmp/test/ install')"
  task :all => [:client, :common, :node, :server]
end
