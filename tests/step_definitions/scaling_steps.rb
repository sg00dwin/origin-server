require 'rubygems'
require 'uri'
require 'fileutils'
require 'json'

include AppHelper

When /^a scaled (.+) application is created$/ do |app_type|
  @app = TestApp.create_unique(app_type)
  # Create our app via the curl api:
  # Replace when the REST API libraries are complete
  rhc_create_domain(@app)
  run("curl -k -H 'Accept: application/json' --user '#{@app.login}:fakepw' https://localhost/broker/rest/domains/#{@app.namespace}/applications -X POST -d name=#{@app.name} -d cartridge=#{app_type} -d scale=true > /tmp/rhc/json_response_#{@app.name}_#{@app.namespace}.json")
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
  gear_count = `/usr/bin/curl -H 'Host: #{@app.name}-#{@app.namespace}.dev.rhcloud.com' -s 'http://localhost/haproxy-status/;csv' | grep -c "express,gear"`.to_i
  gear_count == count
end

Then /^the php-5.3 health\-check will( not)? be successful$/ do |negate|
  good_status = negate ? 1 : 0

  command = "/usr/bin/curl -H 'Host: #{@app.name}-#{@app.namespace}.dev.rhcloud.com' -s 'http://localhost/health_check.php' | grep -q -e '^1$'"
  exit_status = runcon command, 'unconfined_u', 'unconfined_r', 'unconfined_t'
  exit_status.should == good_status
end

When /^a gear is added$/ do
  ssh_cmd = "ssh -t #{@app.uid}@#{@app.hostname} rhcsh haproxy_ctl -u"

  stdout, stdin, pid = PTY.spawn ssh_cmd

  @ssh_cmd = {
    :pid => pid,
    :stdin => stdin,
    :stdout => stdout,
  }
end

When /^a gear is removed$/ do
  ssh_cmd = "ssh -t #{@app.uid}@#{@app.hostname} rhcsh haproxy_ctl -d"

  stdout, stdin, pid = PTY.spawn ssh_cmd

  @ssh_cmd = {
    :pid => pid,
    :stdin => stdin,
    :stdout => stdout,
  }
end
