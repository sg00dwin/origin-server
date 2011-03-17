require 'libra'
require 'resolv'
include Libra
include Libra::Test::User
include Libra::Test::Util

Given /^at least one server$/ do
  servers = Server.find_all

  raise "No servers available" if servers.empty?
end

Given /^an available server$/ do
  @server = Server.find_available
  @server.should_not be_nil
end

When /^I find an available server$/ do
  @result = Server.find_available
end

When /^I create a '(\w+)' app for '(.+)'$/ do |app, framework|
  @app = app
  Libra.execute(framework, 'configure', @app, @user.rhlogin, 'redhat')
end

Then /^the user should have the app on one server$/ do
  host = "#{@app}-#{@user.namespace}.rhcloud.com"
  host_ip = Resolv::DNS.new.getresource(host, Resolv::DNS::Resource::IN::A).address.to_s
  host_ip.should_not be_nil
end

Then /^I should get a result$/ do
  @result.should_not be_nil
end
