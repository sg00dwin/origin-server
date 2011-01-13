require 'libra'
include Libra

Given /^an existing customer named '([a-zA-Z0-9]+)'$/ do |name|
  result = UserHelper.exists(name, @options)
  raise UserNotFound if result.empty?

  # Otherwise, verify that the specific lookup works
  UserHelper.exists_on_server(result[0], name, @options).should be_true
end
