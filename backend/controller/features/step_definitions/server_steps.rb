require 'libra'
include Libra

Given /^at least one server$/ do
  servers = Server.find_all

  raise "No servers available" if servers.empty?
end


When /^I try to find an available server$/ do
  Server.find_available.should_not be_empty
end

Then /^I should get a result$/ do

end
