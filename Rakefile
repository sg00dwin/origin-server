require 'rbconfig'

DEST_DIR = ENV["DESTDIR"] || "/"
BIN_DIR = ENV["BINDIR"] || "#{DEST_DIR}/usr/bin"
FACTER_DIR = ENV["FACTERDIR"] || "#{DEST_DIR}/#{Config::CONFIG['sitelibdir']}/facter"
MCOLLECTIVE_DIR = ENV["MCOLLECTIVEDIR"] || "#{DEST_DIR}/usr/libexec/mcollective/mcollective/agent/"

CLIENT_FILES = ["client/create_customer.rb",
                "client/create_http.rb",
                "client/destroy_http.rb"]

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
    mkdir_p "#{FACTER_DIR}"
    cp "backend/facter/libra.rb", FACTER_DIR
    mkdir_p "#{MCOLLECTIVE_DIR}"
    cp "backend/mcollective/libra.rb", MCOLLECTIVE_DIR
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
    puts ""
    puts "Example: rake DESTDIR='/tmp/test/' install_client"
end
