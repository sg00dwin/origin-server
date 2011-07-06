require 'mcollective'
require 'logger'
require 'openshift'
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
$ctl_app_script = "/usr/bin/rhc-ctl-app"
$user_info_script = "/usr/bin/rhc-user-info"

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
      def create_test_user(user_spec)
        Libra::User.create(user_spec[:login], 
                           $test_ssh_key, 
                           user_spec[:namespace])
      end
    end

    module Util
      #
      # Run a command with logging.  If the command
      # returns a non-zero error code, raise an exception
      #
      def run(cmd)
          $logger.info("Running: #{cmd}")

          pid, stdin, stdout, stderr = Open4::popen4(cmd)

          stdin.close
          ignored, status = Process::waitpid2 pid
          exit_code = status.exitstatus

          $logger.info("Standard Output:\n#{stdout.read}")
          $logger.info("Standard Error:\n#{stderr.read}")

          $logger.error("(#{$$}): Execution failed #{cmd} with exit_code: #{exit_code.to_s}") if exit_code != 0
          return exit_code
      end

      # run a command in an alternate SELinux context
      def runcon(cmd, user=nil, role=nil, type=nil)
        prefix = 'runcon'
        prefix += (' -u ' + user) if user
        prefix += (' -r ' + role) if role
        prefix += (' -t ' + type) if type
        fullcmd = prefix + " " + cmd

        puts "runcon: #{fullcmd}"
        pid, stdin, stdout, stderr = Open4::popen4(fullcmd)

        stdin.close
        ignored, status = Process::waitpid2 pid
        exit_code = status.exitstatus

        $logger.info("Standard Output:\n#{stdout.read}")
        $logger.info("Standard Error:\n#{stderr.read}")

        $logger.error("(#{$$}): Execution failed #{cmd} with exit_code: #{exit_code.to_s}") if exit_code != 0
        return exit_code
      end

      def curl(url)
          pid, stdin, stdout, stderr = Open4::popen4("curl -s #{url}")

          stdin.close
          ignored, status = Process::waitpid2 pid
          exit_code = status.exitstatus
          body = stdout.read

          return exit_code, body
      end

      def add_failure(url, pid=$$)
        system("flock /tmp/rhc/lock echo '#{url}' >> #{$temp}/#{pid}-failures.log")
      end

      def urls_from_files(pattern)
        results = []
        Dir.glob(pattern).each do |file|
          File.new(file, "r").each {|line| results << line.chomp}
        end
        results
      end

      def failures
        urls_from_files("#{$temp}/*-failures.log")
      end

      def add_success(url, pid=$$)
        system("echo '#{url}' >> #{$temp}/#{pid}-success.log")
      end

      def successes(pattern="*")
        urls_from_files("#{$temp}/#{pattern.to_s}-success.log")
      end

      def wait(pid, expected_urls, timeout=300)
        begin
          Timeout::timeout(timeout) do
            Process.wait(pid)
            $logger.error("Process #{pid} failed") if $?.exitstatus != 0
          end
        rescue Timeout::Error
          $logger.error("Process #{pid} timed out")
          # Log the remaining url's as failures
          failed_urls = expected_urls - successes(pid)
          $logger.error("Recording the following urls as failed = #{failed_urls.pretty_inspect}")
          failed_urls.each {|url| add_failure(url, pid)}
        end
      end

      def connect(host, uri, max_retries=30)
          max_retries = 30 unless max_retries

          # Defaults
          code = -1
          body = nil

          url = "http://#{host}/#{uri}"
          $logger.info("Connecting to #{url}")
          beginning_time = Time.now
          begin
            retries = 1
            success = false
            while retries < max_retries and !success do
              begin
                Timeout::timeout(1) do
                  code, body = curl(url)

                  # Only break if the code is 0
                  if code == 0
                    success = true
                  else
                    $logger.info("Connection failed / retry #{retries} / #{url}")
                    sleep 1
                  end
                end
              rescue Timeout::Error
                raise "Timeout #{url}" unless retries < max_retries
                $logger.info("Connection timed out / retry #{retries} / #{url}")
              ensure
                retries += 1
              end
            end
          rescue Exception => e
            $logger.error "Connection exception / #{url}"
            $logger.error e.message
            $logger.error e.backtrace
          end
          response_time = Time.now - beginning_time
          $logger.info("Connection result = #{code} / #{url}")
          $logger.info("Connection response time = #{response_time} / #{url}")

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
