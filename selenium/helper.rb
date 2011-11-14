#!/usr/bin/env ruby
require "rubygems"
require "sauce"
require 'socket'
require 'net/http'
require 'net/https'
require 'zipruby'


# helper for obtaining hostname
def get_my_hostname
  # Set localhost to be the default
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

# This should go in your test_helper.rb file if you have one
Sauce.config do |config|
  if !ENV["SAUCE_BROWSER_URL"]
    config.browser_url = "https://#{get_my_hostname}"
  end
  config.javascript_framework = :jquery

  # uncomment this if your server is not publicly accessible
  # config.application_host = get_my_hostname
  # config.application_port = "443"
end

# Get the Sauce configuration information
@cfg = Sauce::Config.new()

puts "Running tests against: #{@cfg.browser_url}"

ready_file = 'sauce_ready'
@sauce_file = 'Sauce-Connect.jar'
def rest(path)
  uri = URI.parse("https://saucelabs.com/")
  path = "/rest/v1/#{@cfg.opts[:username]}/#{path}"

  # Set the http object
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  req = Net::HTTP::Get.new(path)
  req.basic_auth @cfg.opts[:username], @cfg.opts[:access_key]

  http.request(req).body
end

def tunnel_id
  JSON.parse(rest('tunnels'))[0]
end

# Test to check whether or not a tunnel already exists
def tunnel_exists?
  print "Checking for existing tunnel..."

  id = tunnel_id

  found = false
  if id
    hash = JSON.parse(rest("tunnels/#{id}"))
    found = hash['status'] == 'running'
  end
  puts found ? "found" : "not found"
  found
end

def ensure_sauce_jar_exists
  print "Checking for #{@sauce_file}..."
  if File.exists?(@sauce_file)
    puts "found"
  else
    puts "not found"

    print "Fetching #{@sauce_file}..."
    url = "http://saucelabs.com/downloads/Sauce-Connect-latest.zip"

    Zip::Archive.open_buffer(Net::HTTP.get(URI.parse(url))) do |zf|
      zf.fopen(@sauce_file) do |f|
        open(@sauce_file,'wb') do |file|
          file.write(f.read)
        end
      end
    end
    puts "done"
  end
end

old_sync = STDOUT.sync
STDOUT.sync = true
unless tunnel_exists?
  ensure_sauce_jar_exists

  print "Starting Sauce Connect..."
  # Create a command to spawn the jar file
  cmd = "java -jar #{@sauce_file} -f #{ready_file} #{@cfg.opts[:username]} #{@cfg.opts[:access_key]}"

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
