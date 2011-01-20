require 'libra'
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
  # Create the user on the server
  @server.create_user(@user)

  # Create the app on the server
  @app = app
  @server.execute(framework, 'configure', app, @user)
end

Then /^the user should have the app on one server$/ do
  count = 0
  @user.apps_by_server.each_value do |app|
    count += 1 if app == @app
    raise "App on too many servers" if count > 1
  end
end

Then /^I should get a result$/ do
  @result.should_not be_nil
end
