$LOAD_PATH << File.expand_path('../../../server/lib', __FILE__)
require 'mcollective'
require 'logger'
require 'libra'
require 'timeout'
require 'logger'
require 'fileutils'
require 'open4'
require 'pp'

World(MCollective::RPC)

#
# Define global variables
#
$curr_dir = File.expand_path(File.dirname(__FILE__))
$mc_client_cfg = File.expand_path("#{$curr_dir}/../misc/mcollective-client.cfg")
$domain = "dev.rhcloud.com"
$temp = "/tmp/rhc"
$create_app_script = "/usr/bin/rhc-create-app"
$create_domain_script = "/usr/bin/rhc-create-domain"
$client_config = "/etc/openshift/express.conf"

# RSA Key constants
$libra_pub_key = File.expand_path("~/.ssh/libra_id_rsa.pub")
$libra_priv_key = File.expand_path("~/.ssh/libra_id_rsa")
$test_priv_key = File.expand_path("#{$curr_dir}/../misc/libra_id_rsa")
$test_pub_key = File.expand_path("#{$curr_dir}/../misc/libra_id_rsa.pub")

# Create the temporary space
FileUtils.mkdir_p $temp

# Remove all temporary data
FileUtils.rm_f Dir.glob(File.join($temp, "*"))

module Libra
  module Test
    module User
      #
      # Obtain a unique username from S3.
      #
      #   reserved_usernames = A list of reserved names that may
      #     not be in the global store
      #
      def get_unique_username(reserved_usernames=[])
        result={}

        loop do
          # Generate a random username
          chars = ("1".."9").to_a
          namespace = "ci" + Array.new(8, '').collect{chars[rand(chars.size)]}.join
          login = "libra-test+#{namespace}@redhat.com"
          $logger.info("li - checking availability of namespace = #{namespace}")
          has_txt = Libra::Server.has_dns_txt?(namespace)
          $logger.info("li - has_txt = #{has_txt}")

          $logger.info("li - checking availability of login = #{login}")
          user = Libra::User.find(login)
          $logger.info("li - user = #{user.pretty_inspect}")

          unless user or has_txt or reserved_usernames.index(login)
            result[:login] = login
            result[:namespace] = namespace
            break
          end
        end

        $logger.info("li - returning username = #{result}")

        return result
      end

      #
      # Create a user with a unique username and a testing
      # email and ssh key
      #
      def create_unique_test_user
        @user = create_test_user(get_unique_username)
      end

      #
      # Create a user with the supplied username and a testing
      # email and ssh key
      #
      def create_test_user(rhlogin)
        Libra::User.create(rhlogin, $test_ssh_key, get_unique_namespace)
      end
    end

    module Util
      #
      # Run a command with logging.  If the command
      # returns a non-zero error code, raise an exception
      #
      def run(cmd)
          $logger.info("(#{$$}) Running: #{cmd}")

          pid, stdin, stdout, stderr = Open4::popen4(cmd)

          stdin.close
          ignored, status = Process::waitpid2 pid
          exit_code = status.exitstatus

          $logger.info("(#{$$}) Standard Output:\n#{stdout.read}")
          $logger.info("(#{$$}) Standard Error:\n#{stderr.read}")

          $logger.error("(#{$$}): Execution failed #{cmd}") if exit_code != 0
          raise "ERROR - Non-zero (#{exit_code}) exit code for #{cmd}" if exit_code != 0

          return exit_code
      end

      def curl(url)
          $logger.info("(#{$$}) Accessing: #{url}")

          pid, stdin, stdout, stderr = Open4::popen4("curl -s #{url}")

          stdin.close
          ignored, status = Process::waitpid2 pid
          exit_code = status.exitstatus
          body = stdout.read

          $logger.info("(#{$$}) Exit code: #{exit_code}")
          $logger.info("(#{$$}) Body:\n#{stdout.read}")
          $logger.info("(#{$$}) Standard Error:\n#{stderr.read}")
          $logger.error("(#{$$}) Access failed #{cmd}") if exit_code != 0

          return exit_code, body
      end

      def connect(host, uri, max_retries=30)
          max_retries = 30 unless max_retries

          # Defaults
          code = -1
          body = nil

          url = "http://#{host}/#{uri}"
          $logger.info("(#{$$}) Connecting to #{url}")
          beginning_time = Time.now
          begin
            retries = 1
            success = false
            while retries < max_retries and !success do
              begin
                Timeout::timeout(1) do
                  code, body = curl(url)
                  success = true
                end
              rescue Timeout::Error
		retries += 1
                raise "Timeout #{url}" unless retries < max_retries
                $logger.info("(#{$$}) Timeout on attempt #{retries} to #{url}")
              end
            end
          rescue Exception => e
            $logger.error "(#{$$}) Exception trying to access #{url}"
            $logger.error e.message
            $logger.error e.backtrace
          end
          response_time = Time.now - beginning_time
          $logger.info("(#{$$}) Exit code of #{url} = #{code}")
          $logger.info("(#{$$}) Response time of #{url} = #{response_time}")

          # Yield the response code, time
          yield code, response_time, body if block_given?
      end
    end
  end
end

# Global, one time setup
$logger = Logger.new(File.join($temp, "cucumber.log"))
$logger.level = Logger::DEBUG
$logger.formatter = proc { |severity, datetime, progname, msg|
    "#{$$} #{severity} #{datetime}: #{msg}\n"
}
Libra.c[:logger] = $logger
Libra.c[:bypass_user_reg] = true
#Libra.c[:rpc_opts][:verbose] = true

# Setup the MCollective options
Libra.c[:rpc_opts][:config] = $mc_client_cfg

# Setup test user info
$test_ssh_key = ssh_key = File.open($test_pub_key).gets.chomp.split(' ')[1]

# Default the maximum number of processes
@max_processes = 2

# Setup the default keys if necessary
FileUtils.cp $test_pub_key, $libra_pub_key if !File.exists?($libra_pub_key)
FileUtils.cp $test_priv_key, $libra_priv_key if !File.exists?($libra_priv_key)
FileUtils.chmod 0600, $libra_priv_key
