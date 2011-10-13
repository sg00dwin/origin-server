#!/usr/bin/env ruby
require "rubygems"
require "sauce"
require 'socket'

# Load OpenShift modules

hostname = Socket.gethostbyname(Socket.gethostname).first

# This should go in your test_helper.rb file if you have one
Sauce.config do |config|
  config.browser_url = "https://#{hostname}"
  config.javascript_framework = :jquery

  # uncomment this if your server is not publicly accessible
  # config.application_host = hostname 
  # config.application_port = "443"
end

@ready_file = 'sauce_ready'

# Get the Sauce configuration information
cfg = Sauce::Config.new()
# Create a command to spawn the jar file
cmd = "java -jar Sauce-Connect.jar -f #{@ready_file} #{cfg.opts[:username]} #{cfg.opts[:access_key]}"

# Run the command
`#{cmd} > /dev/null 2>&1 &`
@pid = $?.pid
puts "Connect PID: #{@pid}"

# Wait for Sauce to be ready
until File.exists?(@ready_file)
  puts "Waiting for Sauce Connect"
  sleep 5
end

# Make sure to finish things off when the tests are done
MAIN_TITLE = "OpenShift by Red Hat"
