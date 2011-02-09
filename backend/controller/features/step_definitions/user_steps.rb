require 'libra'
include Libra
include Libra::Test::User
include Libra::Test::Util

Given /^an existing '(\w+)' user$/ do |username|
  # Make sure the given user exists
  unless User.find(username)
    create_test_user(username)
  end
end

Given /^a newly created user$/ do
  @user = create_unique_test_user
end

When /^I modify and update the user$/ do
  @user.email = "blah@example.org"
  @user.update
end

When /^I create a '(\w+)' user$/ do |username|
  lambda {
    create_test_user(username)
  }.should throw_symbol(:user_exists)

  @failed = true
end

When /^I look up that user$/ do
  @user = User.find(@user.username)
end

Then /^I should get an exception$/ do
  @failed.should be_true
end

Then /^he should have no servers$/ do
  @user.servers.should be_empty
end

Then /^he should have no applications$/ do
  @user.apps.should be_empty
end

Then /^the changes are saved$/ do
  @user_saved = User.find(@user.username)
  @user_saved.email.should == "blah@example.org"
end
