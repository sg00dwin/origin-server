require 'pp'

Given /^the libra client tools$/ do
  File.exists?("/usr/bin/libra_create_app").should be_true
  File.exists?("/usr/bin/libra_create_customer").should be_true
  File.exists?("/etc/libra/client.conf").should be_true
end

When /^(\d+) new customers are created$/ do |num_customers|
  puts "Created #{num_customers}"
end

When /^(\d+) applications of type '(.+)' are created per customer$/ do |num_apps, framework|
  puts "Num apps #{num_apps}"
  puts "Framework #{framework}"
end

Then /^they should all be accessible$/ do

end
