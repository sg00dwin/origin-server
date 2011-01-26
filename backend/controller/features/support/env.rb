$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
require 'mcollective'
require 'libra'
require 'timeout'
require 'logger'
require 'fileutils'

World(MCollective::RPC)

#
# Define global variables
#
$domain = "rhcloud.com"
$temp = "/tmp/rhc"
$email = "noone@example.com"
$create_app_script = "/usr/bin/rhc-create-app"
$create_user_script = "/usr/bin/rhc-create-user"
$client_config = "/etc/libra/client.conf"

# Create the temporary space
FileUtils.mkdir_p $temp

# Remove all temporary data
FileUtils.rm_f Dir.glob(File.join($temp, "*"))
FileUtils.rm_f File.join(File.expand_path("~"), "/.ssh/known_hosts")

module Libra
  module Test
    module User
      #
      # Obtain a unique username from S3.
      #
      #   sprint = The number of the sprint which, if supplied,
      #     will be added as a prefix to the username to result
      #     in something like "sprint1username"
      #   reserved_usernames = A list of reserved names that may
      #     not be in the global store
      #
      def get_unique_username(sprint=nil, reserved_usernames=[])
        result=nil

        loop do
          # Generate a random username
          chars = ("1".."9").to_a
          prefix = sprint ? "sprint#{sprint}" : "test"
          username = prefix + Array.new(5, '').collect{chars[rand(chars.size)]}.join
          $logger.info("attempting = #{username}")

          user = Libra::User.find(username)

          $logger.info("looked up user = #{user}")

          unless user or reserved_usernames.index(username)
            result = username
            break
          end
        end

        $logger.info("returning username = #{result}")

        return result
      end

      #
      # Create a user with a unique username and a testing
      # email and ssh key
      #
      def create_unique_test_user(sprint=nil)
        @user = create_test_user(get_unique_username(sprint))
      end

      #
      # Create a user with the supplied username and a testing
      # email and ssh key
      #
      def create_test_user(username)
        Libra::User.create(username, @test_ssh_key, @test_email)
      end
    end

    module Util
      #
      # Run a command with logging.  If the command
      # returns a non-zero error code, raise an exception
      #
      def run(cmd)
          $logger.info("Running: #{cmd}")

          output = `#{cmd} 2>&1`
          exit_code = $?

          # Raise an exception on a non-zero exit code
          unless exit_code.to_i
            $logger.error("ERROR running #{cmd}.  Output:\n#{output}")
            raise RuntimeError, "Running #{cmd} failed"
          else
            $logger.info("Output :\n#{output}")
          end

          return exit_code
      end
    end
  end
end

#
# Cucumber test setup
#
Before do
  # Setup the MCollective options
  Libra.c[:rpc_opts][:config] = "test/etc/client.cfg"

  # Setup test user info
  @test_ssh_key = ssh_key = File.open("test/id_rsa.pub").gets.chomp.split(' ')[1]
  @test_email = "libra-test@redhat.com"

  # Default the maximum number of processes
  @max_processes = 10
end

# Global, one time setup
$logger = Logger.new(File.join($temp, "cucumber.log"))
$logger.level = Logger::DEBUG
Libra.c[:logger] = $logger
