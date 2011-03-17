$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
require 'mcollective'
require 'libra'
require 'timeout'
require 'logger'
require 'fileutils'
require 'open3'

World(MCollective::RPC)

#
# Define global variables
#
$domain = "rhcloud.com"
$temp = "/tmp/rhc"
$email = "noone@example.com"
$create_app_script = "/usr/bin/rhc-create-app"
$create_user_script = "/usr/bin/rhc-create-domain"
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
        Libra::User.create(@test_email, @test_ssh_key, username)
      end
    end

    module Util
      #
      # Run a command with logging.  If the command
      # returns a non-zero error code, raise an exception
      #
      def run(cmd)
          $logger.info("Running: #{cmd}")

          # Open up IO pipes for the sub process communication
          rd1, wr1 = IO.pipe
          rd2, wr2 = IO.pipe

          # Fork a subprocess so we can get an accurate return code
          # In Ruby 1.9, we can replace this with Process.spawn
          pid = fork do
            rd1.close
            rd2.close
            $stdout.reopen(wr1)
            $stderr.reopen(wr2)
            exec(cmd)
            raise "Command execution failed - #{cmd}"
          end

          # Close the end of the pipe we aren't using
          wr1.close
          wr2.close

          # Wait for the process to complete and get the exit code
          Process.wait(pid)
          exit_code = $?.exitstatus

          $logger.error("Standard Output:\n#{rd1.read}")
          $logger.info("Standard Error:\n#{rd2.read}")

          # Close out the streams
          rd1.close
          rd2.close

          raise "ERROR - Non-zero (#{exit_code}) exit code for #{cmd}" if exit_code != 0

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
