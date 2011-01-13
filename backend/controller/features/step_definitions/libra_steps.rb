require 'libra'
include Libra

Given /^an existing '([a-zA-Z0-9]+)' user$/ do |username|
  # Make sure the given user exists
  unless User.find(username)
    User.create(username, 'blah', 'blah@example.org')
  end
end

When /^I try to create a '([a-zA-Z0-9]+)' user$/ do |username|
  lambda {
    User.create(username, 'blah', 'blah@example.org')
  }.should throw_symbol(:user_exists)
end

Then /^I should get an exception$/ do
end
