$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
require 'mcollective'
require 'libra'

World(MCollective::RPC)

def create_test_user(username)
  User.create(username, @test_ssh_key, @test_email)
end

Before do
  # Setup the MCollective options
  Libra.c[:rpc_opts][:config] = "test/etc/client.cfg"

  # Setup test user info
  @test_ssh_key = ssh_key = File.open("test/id_rsa.pub").gets.chomp.split(' ')[1]
  @test_email = "libra-test@redhat.com"
end
