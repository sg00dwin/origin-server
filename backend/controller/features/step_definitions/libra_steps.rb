require 'libra'
include Libra

Given /^an existing customer named '([a-zA-Z0-9]+)'$/ do |name|
  puts User.find_all_usernames
  #user = User.find('mmcgrath')
  #pp user.servers
  #pp user.apps
  #pp user.apps_by_server
  #result = User.exists(name, @options)
  #raise UserNotFound if result.empty?

  # Otherwise, verify that the specific lookup works
  #User.exists_on_server(result[0], name, @options).should be_true
end
