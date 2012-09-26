require "rubygems"
require "sauce"
require "json"
require 'socket'
require 'net/http'
require 'net/https'
require 'zip'

module OpenShift
  module SauceHelper
    def sauce_filename
      'Sauce-Connect.jar'
    end

    def build_driver(opts)
      @config = Sauce::Config.new(opts)
      http_client = ::Selenium::WebDriver::Remote::Http::Default.new
      http_client.timeout = 300 # Browser launch can take a while

      caps = @config.to_desired_capabilities

      if ENV["SAUCE_SELENIUM_VERSION"]
        caps["selenium-version"] = ENV["SAUCE_SELENIUM_VERSION"]
      end

      @driver = ::Selenium::WebDriver.for(:remote, :url => "http://#{@config.username}:#{@config.access_key}@#{@config.host}:#{@config.port}/wd/hub", :desired_capabilities => caps, :http_client => http_client)
      http_client.timeout = 90 # Once the browser is up, commands should time out reasonably

      return @driver
    end

    def session_id
      @driver.send(:bridge).session_id
    end

    def put(path, body, headers={}, config={})
      cfg = Sauce::Config.new()
      uri = URI.parse("https://saucelabs.com/")
      path = "/rest/v1/#{cfg.opts[:username]}/#{path}"

      # Set the http object
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = Net::HTTP::Put.new(path, headers)
      req.body = body
      req.basic_auth cfg.opts[:username], cfg.opts[:access_key]

      http.request(req).body
    end

    def get(path)
      cfg = Sauce::Config.new()
      uri = URI.parse("https://saucelabs.com/")
      path = "/rest/v1/#{cfg.opts[:username]}/#{path}"

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = Net::HTTP::Get.new(path)
      req.basic_auth cfg.opts[:username], cfg.opts[:access_key]

      http.request(req).body
    end

    def set_meta(job_id, meta)
      put("jobs/#{job_id}", meta.to_json, {"Content-type" => "text/json"})
    end

    def tunnel_id
      JSON.parse(get('tunnels'))[0]
    end

    def get_my_hostname
      hostname = 'localhost'

      # See if there is a hostname for this machine in /etc/hosts
      begin
        hostname = Socket.gethostbyname(Socket.gethostname).first
      rescue SocketError
        puts "Not able to resolve local hostname"
      rescue
        puts "No local hostname given"
      end

      # Check to see if we're running on an EC2 machine
      begin
        url = 'http://169.254.169.254/latest/meta-data/public-hostname'
        hostname = Net::HTTP.get_response(URI.parse(url)).body
      rescue Errno::EHOSTUNREACH
        puts "Not running on EC2"
      end

      return hostname
    end

    # Test to check whether or not a tunnel already exists
    def tunnel_exists?
      print "Checking for existing tunnel..."

      id = tunnel_id

      found = false
      if id
        hash = JSON.parse(get("tunnels/#{id}"))
        found = hash['status'] == 'running'
      end
      puts found ? "found" : "not found"
      found
    end

    def ensure_sauce_jar_exists
      sauce_file = sauce_filename
      print "Checking for #{sauce_file}..."
      if File.exists?(sauce_file)
        puts "found"
      else
        puts "not found"

        print "Fetching #{sauce_file}..."
        url = "http://saucelabs.com/downloads/Sauce-Connect-latest.zip"

        tmp=`mktemp`

        resp_body = Net::HTTP.get_response(URI.parse(url)).body
        File.open(tmp, "wb") do |file|
          file.write(resp_body)
        end

        Zip::ZipFile::open(tmp) do |zf|
          zf.each do |f|
            if f.name =~ /.jar$/
              zf.extract(f, sauce_file) unless File.exists?(sauce_file)
            end
          end
        end

        File.delete(tmp)

        puts "done"
      end
    end

    def ensure_tunnel
      old_sync = STDOUT.sync
      STDOUT.sync = true
      unless tunnel_exists?
        cfg = Sauce::Config.new()
        ensure_sauce_jar_exists

        ready_file = 'sauce_ready'

        print "Starting Sauce Connect..."
        # Create a command to spawn the jar file
        java_options = "-Djsse.enableSNIExtension=false" # bypasses java SSL issue
        cmd = "java #{java_options} -jar #{sauce_filename} -f #{ready_file} #{cfg.opts[:username]} #{cfg.opts[:access_key]}"

        # Run the command
        `#{cmd} > /dev/null 2>&1 &`
        @sauce_connect_pid = $?.pid
        puts "done"

        # Wait for Sauce to be ready
        print "Waiting for Sauce Connect"
        until File.exists?(ready_file)
          print '.'
          sleep 5
        end
        puts 'ready'
      end
      STDOUT.sync = old_sync
    end

    def close_tunnel
      # HACK: pid is of the `cmd`, which spawns java
      if @sauce_connect_pid
        Process.kill('TERM', @sauce_connect_pid+1)
      end
    end
  end
end
