require 'libra'
include Libra

Given /^an existing '([a-zA-Z0-9]+)' user$/ do |username|
  # Make sure the given user exists
  unless User.find(username)
    create_test_user(username)
  end
end

When /^I try to create a '([a-zA-Z0-9]+)' user$/ do |username|
  lambda {
    create_test_user(username)
  }.should throw_symbol(:user_exists)
end

Then /^I should get an exception$/ do
end

Given /^a newly created user$/ do
  user = "match"

  while user do
    # Generate a random username
    chars = ("1".."9").to_a
    username = "test" + Array.new(5, '').collect{chars[rand(chars.size)]}.join
    user = User.find(username)
  end

  @user = create_test_user(username)
end

When /^I look up that user$/ do
  @user = User.find(@user.username)
end

Then /^he should have no servers$/ do
  @user.servers.should be_empty
end

Then /^he should have no applications$/ do
  @user.apps.should be_empty
  @user.apps_by_server.should be_empty
end
