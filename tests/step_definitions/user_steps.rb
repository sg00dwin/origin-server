require 'libra'
include Libra
include Libra::Test::User
include Libra::Test::Util

Given /^an existing '(.*)' user$/ do |rhlogin|
  # Make sure the given user exists
  unless User.find(rhlogin)
    create_test_user(rhlogin)
  end
end

Given /^a newly created user$/ do
  @user = create_unique_test_user
end

When /^I modify and update the user$/ do
  @user.namespace = "blah"
  @user.update
end

When /^I create a '(.*)' user$/ do |rhlogin|
  lambda {
    create_test_user(rhlogin)
  }.should raise_error(Exception) 

  @failed = true
end

When /^I look up that user$/ do
  @user = User.find(@user.rhlogin)
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
  @user_saved = User.find(@user.rhlogin)
  @user_saved.namespace.should == "blah"
end
