$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
require 'mcollective'
require 'libra'
require 'logger'

World(MCollective::RPC)

# Setup a logger for everyone
@@logger = Logger.new('/tmp/libra-test.log')
@@logger.level = Logger::INFO
Libra.c[:logger] = @@logger

# For threaded operations, the number of threads to use
@@THREADS = 10

def get_unique_username(sprint=nil, reserved_usernames=[])
  result=nil

  @@logger.info("reserved = #{reserved_usernames}")

  loop do
    # Generate a random username
    chars = ("1".."9").to_a
    prefix = sprint ? "sprint#{sprint}" : "test"
    username = prefix + Array.new(5, '').collect{chars[rand(chars.size)]}.join
    @@logger.info("attempting = #{username}")

    user = User.find(username)

    @@logger.info("looked up user = #{user}")

    unless user or reserved_usernames.index(username)
      result = username
      break
    end
  end

  @@logger.info("returning username = #{result}")

  return result
end

def create_unique_test_user(sprint=nil)
  @user = create_test_user(get_unique_username(sprint))
end

def create_test_user(username)
  User.create(username, @test_ssh_key, @test_email)
end

# Run a command with logging.  If the command
# returns a non-zero error code, raise an exception
def run(cmd)
    @@logger.info("Thread #{Thread.current.object_id} / Running command: #{cmd}")

    output = `#{cmd} 2>&1`
    exit_code = $?
    raise RuntimeError, "Thread #{Thread.current.object_id} / Command #{cmd} failed" unless exit_code.to_i

    @@logger.info("Thread #{Thread.current.object_id} / Command output: #{output}")

    return exit_code
end

Before do
  # Setup the MCollective options
  Libra.c[:rpc_opts][:config] = "test/etc/client.cfg"

  # Setup test user info
  @test_ssh_key = ssh_key = File.open("test/id_rsa.pub").gets.chomp.split(' ')[1]
  @test_email = "libra-test@redhat.com"
end
