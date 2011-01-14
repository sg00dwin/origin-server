require 'libra'
include Libra

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
  @server.configure(@user)

  # Create the app on the server
  @app = app
  @server.configure_app(framework, app, @user)
end

Then /^the user should have the app$/ do
  @user.apps.index(@app).should_not == -1
end

Then /^I should get a result$/ do
  @result.should_not be_nil
end
