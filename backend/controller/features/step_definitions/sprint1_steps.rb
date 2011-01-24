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

Given /^(\d+) new users$/ do |num_users|
  # Create an empty array of users to defer
  # creation to the forked process
  @usernames = Array.new(num_users)
end

When /^(\d+) applications of type '(.+)' are created per unique user$/ do |num_apps, framework|
  # Generate the array of apps
  @apps = (num_apps.to_i).times.collect{|num| "app#{num}" }

  # Limit loop on the number of users established in a previous step
  @usernames.each_with_index do |data, index|
    # Get a unique username to create in the forked process
    # and add it to the list of reserved usernames to avoid
    # race conditions of duplicate users
    username = get_unique_user(1, @usernames)
    @usernames[index] = username

    # Fork off the creation of the user and apps
    fork_cmd(username, @max_processes, false) do
      # Create the username on the first run
      run("/usr/bin/libra_create_customer -u #{username} -e nobody@example.com")

      # Then create each of the apps
      @apps.each do |app|
        run("/usr/bin/libra_create_app -u #{username} -a #{app} -r /tmp/libra_repo_#{username}_#{app}_repo -t php-5.3.2 -b")
      end
    end
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
