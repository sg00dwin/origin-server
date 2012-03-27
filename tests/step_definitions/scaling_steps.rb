require 'rubygems'
require 'uri'
require 'fileutils'
require 'json'
require 'pty'

include AppHelper

When /^a scaled (.+) application is created$/ do |app_type|
  @app = TestApp.create_unique(app_type)
  # Create our app via the curl api:
  # Replace when the REST API libraries are complete
  rhc_create_domain(@app)
  run("curl -o /tmp/rhc/json_response_#{@app.name}_#{@app.namespace}.json -k -H 'Accept: application/json' --user '#{@app.login}:fakepw' https://localhost/broker/rest/domains/#{@app.namespace}/applications -X POST -d name=#{@app.name} -d cartridge=#{app_type} -d scale=true")
  fp = File.open("/tmp/rhc/json_response_#{@app.name}_#{@app.namespace}.json")
  json_string = fp.read
  app_info = JSON.parse(json_string)
  @app.uid = app_info['data']['uuid']
  fp.close
end

Then /^the haproxy-status page will( not)? be responding$/ do |negate|
  good_status = negate ? 1 : 0

  command = "/usr/bin/curl -H 'Host: #{@app.name}-#{@app.namespace}.dev.rhcloud.com' -s 'http://localhost/haproxy-status/;csv' | /bin/grep -q -e '^stats,FRONTEND'"
  exit_status = runcon command, 'unconfined_u', 'unconfined_r', 'unconfined_t'
  exit_status.should == good_status
end

Then /^the gear member will( not)? be UP$/ do |negate|
  good_status = negate ? 1 : 0

  command = "/usr/bin/curl -H 'Host: #{@app.name}-#{@app.namespace}.dev.rhcloud.com' -s 'http://localhost/haproxy-status/;csv' | awk -F',' '/express,gear/{ if($18!=\"UP\") exit 1  }'"
  exit_status = runcon command, 'unconfined_u', 'unconfined_r', 'unconfined_t'
  exit_status.should == good_status
end

Then /^(\d+) gears will be in the cluster$/ do |count|
  gear_count = `/usr/bin/curl -H 'Host: #{@app.name}-#{@app.namespace}.dev.rhcloud.com' -s 'http://localhost/haproxy-status/;csv' | grep -c "express,gear"`
  gear_count.to_i == count.to_i
end

Then /^the php-5.3 health\-check will( not)? be successful$/ do |negate|
  good_status = negate ? 1 : 0

  command = "/usr/bin/curl -H 'Host: #{@app.name}-#{@app.namespace}.dev.rhcloud.com' -s 'http://localhost/health_check.php' | grep -q -e '^1$'"
  exit_status = runcon command, 'unconfined_u', 'unconfined_r', 'unconfined_t'
  exit_status.should == good_status
end

When /^a gear is (added|removed)$/ do |action|
  if action == "added"
    ssh_cmd = "ssh -t #{@app.uid}@#{@app.hostname} 'rhcsh haproxy_ctld -u'"
  elsif action == "removed"
    ssh_cmd = "ssh -t #{@app.uid}@#{@app.hostname} 'rhcsh haproxy_ctld -u'"
  else
    puts "Invalid gear action specified (must be added/removed)"
    exit 1
  end

  runcon ssh_cmd, 'unconfined_u', 'unconfined_r', 'unconfined_t'
end

When /^haproxy_ctld_daemon is restarted$/ do
  ssh_cmd = "ssh -t #{@app.uid}@#{@app.hostname} 'rhcsh haproxy_ctld_daemon restart'"

  runcon ssh_cmd, 'unconfined_u', 'unconfined_r', 'unconfined_t'
end

Then /^haproxy_ctld is running$/ do
  ssh_cmd = "ssh -t #{@app.uid}@#{@app.hostname} 'rhcsh ps auxwww | grep -q haproxy_ctld'"
  runcon ssh_cmd, 'unconfined_u', 'unconfined_r', 'unconfined_t'
end

When /^(\d+) concurrent http connections are generated for (\d+) seconds$/ do |concurrent, seconds|
  cmd = "ab -H 'Host: #{@app.name}-#{@app.namespace}.dev.rhcloud.com' -c #{concurrent} -t #{seconds} http://localhost/ > /tmp/rhc/http_load_test_#{@app.name}_#{@app.namespace}.txt"
  exit_status = runcon cmd, 'unconfined_u', 'unconfined_r', 'unconfined_t'
  puts exit_status
  exit_status
end
