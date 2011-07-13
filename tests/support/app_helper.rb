require 'openshift'
require 'active_support'
require 'open4'

module AppHelper
  class TestApp
    include ActiveSupport::JSON

    # attributes to represent the general information of the application
    attr_accessor :name, :namespace, :login, :type, :hostname, :repo, :file, :embed

    # attributes to represent the state of the rhc_create_* commands
    attr_accessor :create_domain_code, :create_app_code

    # attributes that contain statistics based on calls to connect
    attr_accessor :response_code, :response_time

    # Create the data structure for a test application
    def initialize(namespace, login, type, name)
      @name, @namespace, @login, @type = name, namespace, login, type
      @hostname = "#{name}-#{namespace}.#{$domain}"
      @repo = "#{$temp}/#{namespace}_#{name}_repo"
      @file = "#{$temp}/#{namespace}.json"
    end

    def self.create_unique(type, name="test")
      loop do
        # Generate a random username
        chars = ("1".."9").to_a
        namespace = "ci" + Array.new(8, '').collect{chars[rand(chars.size)]}.join
        login = "libra-test+#{namespace}@redhat.com"
        app = TestApp.new(namespace, login, type, name)
        unless app.reserved?
          app.persist
          return app
        end
      end
    end

    def self.find_on_fs
      Dir.glob("#{$temp}/*.json").collect {|f| TestApp.from_file(f)}
    end

    def self.from_file(filename)
      TestApp.from_json(ActiveSupport::JSON.decode(File.open(filename, "r") {|f| f.readlines}[0]))
    end

    def self.from_json(json)
      app = TestApp.new(json['namespace'], json['login'], json['type'], json['name'])
      app.embed = json['embed']
      return app
    end

    def get_log(prefix)
      "#{$temp}/#{prefix}_#{@name}-#{@namespace}.log"
    end

    def persist
      File.open(@file, "w") {|f| f.puts self.to_json}
    end

    def reserved?
      Libra::User.find(login) or Libra::Server.has_dns_txt?(@namespace) or File.exists?(@file)
    end

    def has_domain?
      return create_domain_code == 0
    end

    def get_index_file
      case @type
        when "php-5.3" then "php/index.php"
        when "rack-1.1" then "config.ru"
        when "wsgi-3.2" then "wsgi/application"
        when "perl-5.10" then "perl/index.pl"
        when "jbossas-7.0" then "src/main/webapp/index.html"
      end
    end

    def get_stop_string
      case @type
        when "jbossas-7.0" then "NOT running"
        else "stopped"
      end
    end

    def curl(url, timeout=30)
      pid, stdin, stdout, stderr = Open4::popen4("curl --insecure -s --max-time #{timeout} #{url}")

      stdin.close
      ignored, status = Process::waitpid2 pid
      exit_code = status.exitstatus
      body = stdout.read

      return exit_code, body
    end

    def curl_head(url)
      pid, stdin, stdout, stderr = Open4::popen4("curl --insecure -s --head --max-time 30 #{url} | grep 200")

      stdin.close
      ignored, status = Process::waitpid2 pid
      return status.exitstatus
    end

    def is_inaccessible?(max_retries=60)
      max_retries.times do |i|
        if curl_head("http://#{hostname}") != 0
          return true
        else
          $logger.info("Connection still accessible / retry #{i} / #{hostname}")
          sleep 1
        end
      end

      return false
    end

    def is_accessible?(use_https=false, max_retries=30)
      prefix = use_https ? "https://" : "http://"
      url = prefix + hostname

      max_retries.times do |i|
        if curl_head(url) == 0
          return true
        else
          $logger.info("Connection still inaccessible / retry #{i} / #{url}")
          sleep 1
        end
      end

      return false
    end

    def connect(use_https=false, max_retries=30)
      prefix = use_https ? "https://" : "http://"
      url = prefix + hostname

      $logger.info("Connecting to #{url}")
      beginning_time = Time.now

      max_retries.times do |i|
        code, body = curl(url, 1)

        if code == 0
          @response_code = code.to_i
          @response_time = Time.now - beginning_time
          $logger.info("Connection result = #{code} / #{url}")
          $logger.info("Connection response time = #{@response_time} / #{url}")
          return body
        else
          $logger.info("Connection failed / retry #{i} / #{url}")
          sleep 1
        end
      end

      return nil
    end
  end
end
World(AppHelper)
