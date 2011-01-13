$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
require 'mcollective'
require 'libra'

World(MCollective::RPC)

def create_test_user(username)
  User.create(username, @test_ssh_key, @test_email)
end

Before do
  # Setup a logger
  Libra.logger = Logger.new('/tmp/libra.log')

  # Setup the AWS keys
  Libra.aws_key = ENV['S3_AWS_KEY']
  Libra.aws_secret = ENV['S3_AWS_SECRET']

  # Verify you have the AWS config
  raise "You need to set the S3_AWS_KEY and S3_AWS_SECRET environment variables" unless Libra.aws_key

  # Setup the MCollective options
  Libra.rpc_opts = {:disctimeout => 2,
                    :timeout     => 5,
                    :verbose     => false,
                    :filter      => {"identity"=>[], "fact"=>[], "agent"=>[], "cf_class"=>[]},
                    :config      => "test/etc/client.cfg"}

  # Setup test user info
  @test_ssh_key = ssh_key = File.open("test/id_rsa.pub").gets.chomp.split(' ')[1]
  @test_email = "libra-test@redhat.com"
end
