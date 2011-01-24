$LOAD_PATH << File.expand_path('../../../lib', __FILE__)
require 'mcollective'
require 'libra'
require 'timeout'
require 'logger'
require 'fileutils'

World(MCollective::RPC)

# Remove all logs to begin
FileUtils.rm_f Dir.glob("/tmp/libra*.log")

# Remove all temporary repos
FileUtils.rm_f Dir.glob("/tmp/libra_repo*")

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

      #
      # Fork processes to run the supplied block of code.  Each
      # processes will pop an entry off the in_data array until
      # the array is exhausted.
      #
      #   in_data = an array of data elements to process
      #   max_processes = the number of processes to use
      #   delay = sleep between 0-1 seconds between forks
      #
      def fork_cmd(in_data, max_processes, fail_on_error=true, delay=true)
        # Convert the input argument to an array if necessart
        f_data = Array.try_convert(in_data) ? in_data : Array.new(1, in_data)

        # Create the users in subprocesses
        loop do
          # Don't fork more processes than we have data elements
          num_processes = f_data.length < max_processes ? f_data.length: max_processes

          num_processes.times do |count|
            # Pop a piece of data off the array
            data = f_data.pop

            # Fork off the command
            $logger.info("Forking with data element #{data}")
            fork do
              yield data, count
            end

            # if delaying, sleep to delay forks
            sleep rand if delay
          end

          # Wait for the processes to finish
          num_processes.times do
              # Fail after waiting for 60 seconds
              Timeout::timeout(60) { Process.wait }
              exit_code = $?.exitstatus
              process_id = $?.to_i
              raise "Forking failed / pid=#{process_id} / exit_code=#{exit_code}" if exit_code != 0 and fail_on_error
          end

          # Break if we've processed all the usernames
          break if f_data.empty?
        end
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
$logger = Logger.new("/tmp/libra-cucumber.log")
$logger.level = Logger::DEBUG
Libra.c[:logger] = $logger
