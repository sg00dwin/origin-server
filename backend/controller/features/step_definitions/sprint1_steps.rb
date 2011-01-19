require 'net/http'
require 'uri'
include Libra::Test::User
include Libra::Test::Util

Given /^the libra client tools$/ do
  File.exists?("/usr/bin/libra_create_app").should be_true
  File.exists?("/usr/bin/libra_create_customer").should be_true
  File.exists?("/etc/libra/client.conf").should be_true
end

Given /^(\d+) concurrent processes$/ do |max_processes|
  @max_processes = max_processes.to_i
end

When /^(\d+) new users are created$/ do |num_users|
  num_users = num_users.to_i

  # Come up with the list of usernames to create
  @usernames = []
  num_users.times do
    @usernames << get_unique_username(1, @usernames)
  end

  # Fork off the creation of usernames
  fork_cmd(@usernames, @max_processes) do |username|
    run("/usr/bin/libra_create_customer -u #{username} -e nobody@example.com")
  end
end

When /^(\d+) applications of type '(.+)' are created per user$/ do |num_apps, framework|
  @apps = (num_apps.to_i).times.collect{|num| "app#{num}" }

  # Generate the 'product' of username / app combinations
  user_apps = @usernames.product(@apps)

  # Fork off the creation of apps
  fork_cmd(user_apps, @max_processes) do |user_app|
    username, app = user_app[0], user_app[1]
    run("/usr/bin/libra_create_app -u #{username} -a #{app} -r /tmp/#{username}_#{app}_repo -t php-5.3.2 -b")
  end
end

Then /^they should all be accessible$/ do
  # Generate the 'product' of username / app combinations
  user_apps = @usernames.product(@apps)

  urls = {}
  # Hit the health check page for each app
  user_apps.each do |user_app|
    url = "http://#{user_app[1]}.#{user_app[0]}.libra.mmcgrath.net/health_check.php"
    code = Net::HTTP.get_response(URI.parse(url)).code
    urls[url] = code
  end

  # Print out the results:
  #  Format = code - url
  $logger.info("URL Results")
  urls.each_pair do |url, code|
    $logger.info("#{code} - #{url}")
  end

  # Get all the unique responses
  # There should only be 1 result ["200"]
  uniq_responses = urls.values.uniq
  uniq_responses.length.should == 1
  uniq_responses[0].should == "200"
end
