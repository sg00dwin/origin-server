require 'rbconfig'

DEST_DIR = ENV["DESTDIR"] || "/"
BIN_DIR = ENV["BINDIR"] || "#{DEST_DIR}/usr/bin"
FACTER_DIR = ENV["FACTERDIR"] || "#{DEST_DIR}/#{Config::CONFIG['sitelibdir']}/facter"
MCOLLECTIVE_DIR = ENV["MCOLLECTIVEDIR"] || "#{DEST_DIR}/usr/libexec/mcollective/mcollective/agent/"
INITRD_DIR = ENV["INITRDDIR"] || "#{DEST_DIR}/etc/init.d/"
LIBEXEC_DIR = ENV["LIBEXECDIR"] || "#{DEST_DIR}/usr/libexec/li/"
LIBRA_DIR = ENV["LIBRADIR"] || "#{DEST_DIR}/var/lib/libra"
CONF_DIR = ENV["CONFDIR"] || "#{DEST_DIR}/etc/libra"
CLIENT_FILES = ["client/create_customer.rb",
                "client/create_app.rb"]

NODE_FILES = ["backend/facter/libra.rb",
              "backend/mcollective/libra.rb"]

#
# Test client files
#
task :test_client do
    CLIENT_FILES.each{|client_file| sh "ruby", "-c", client_file}
end

# 
# Install client files
#
task :install_client => [:test_client] do
    mkdir_p "#{DEST_DIR}/usr/bin/"
    CLIENT_FILES.each {|client_name|
        new_name = File.basename(client_name).gsub(/^/, "libra_").gsub(/.rb$/, '')
        cp client_name, "#{BIN_DIR}/#{new_name}"
    }
end

#
# Test node files
#
task :test_node do
    NODE_FILES.each{|node_file| sh "ruby", "-c", node_file}
end

# 
# Install node files
#
task :install_node => [:test_node] do
    mkdir_p FACTER_DIR
    cp "backend/facter/libra.rb", FACTER_DIR
    mkdir_p MCOLLECTIVE_DIR
    cp "backend/mcollective/libra.rb", MCOLLECTIVE_DIR
    mkdir_p INITRD_DIR
    cp "backend/scripts/libra", INITRD_DIR
    cp "backend/scripts/libra-data", INITRD_DIR
    mkdir_p BIN_DIR
    cp "backend/scripts/trap-user", BIN_DIR
    mkdir_p LIBRA_DIR
    mkdir_p "#{DEST_DIR}/usr/share/selinux/packages"
    cp "backend/selinux/libra.pp", "#{DEST_DIR}/usr/share/selinux/packages"
end

# 
# Install cartridges
#
task :install_cartridges do
    mkdir_p LIBEXEC_DIR
    cp_r "cartridges/", LIBEXEC_DIR
    mkdir_p CONF_DIR
    sh "ln", "-s", "#{LIBEXEC_DIR}/cartridges/li-controller-0.1/info/configuration/node.conf-sample", "#{CONF_DIR}/node.conf"
end

# 
# Test server
#
task :test_server do
    cd "backend/controller"
    sh "rake", "cuc"
    cd "../.."
end

# 
# Install server
#
task :install_server do
    mkdir_p MCOLLECTIVE_DIR
    cp "backend/mcollective/libra.ddl", MCOLLECTIVE_DIR
    mkdir_p BIN_DIR
    cp "backend/controller/bin/mc-libra", "#{BIN_DIR}/mc-libra"
    cp "backend/controller/bin/new-user", "#{BIN_DIR}/new-user"
    mkdir_p CONF_DIR
    cp "backend/controller/conf/libra_s3.conf", CONF_DIR
    cd "backend/controller"
    sh "rake"
end

# 
# Install all
#
task :install => [:install_client, :install_node, :install_cartridges, :install_server] do
end

# 
# print help
#
task :default do
    puts "Specify a rake option:"
    puts ""
    puts "  install_client      Install client files"
    puts "  test_client         Test client files"
    puts "  install_node        Install node files"
    puts "  test_node           Test node files"
    puts "  install_cartridges  Install cartridges"
    puts "  test_server         Test server files"
    puts "  install_server      Install server"
    puts "  install             Install all"
    puts ""
    puts "Example: rake DESTDIR='/tmp/test/' install_client"
end
