require 'net/http'
require 'uri'
include Libra::Test::User
include Libra::Test::Util

Given /^the libra client tools$/ do
  File.exists?($create_app_script).should be_true
  File.exists?($create_user_script).should be_true
  File.exists?($client_config).should be_true
end

Given /^(\d+) concurrent processes$/ do |max_processes|
  @max_processes = max_processes.to_i
end

Given /^(\d+) new users$/ do |num_users|
  # Create an empty array of users to defer
  # creation to the forked process
  @usernames = Array.new(num_users.to_i)
end

When /^(\d+) applications of type '(.+)' are created per user$/ do |num_apps, framework|
  # Generate the array of apps
  @apps = (num_apps.to_i).times.collect{|num| "app#{num}" }

  # Limit loop on the number of users established in a previous step
  @usernames.each_with_index do |data, index|
    # Get a unique username to create in the forked process
    # and add it to the list of reserved usernames to avoid
    # race conditions of duplicate users
    username = get_unique_username(1, @usernames)
    @usernames[index] = username

    # Generate the 'product' of username / app combinations
    user_apps = @apps.collect {|app| [username, app]}

    # Fork off the creation of the user and apps
    fork_cmd(user_apps, @max_processes, false) do |user_app, count|
      # Parse out the data structure
      username, app = user_app[0], user_app[1]

      # Create the username on the first run
      run("#{$create_user_script} -u #{username} -e #{$email}") if count == 0

      # Run the app each time
      run("#{$create_app_script} -u #{username} -a #{app} -r #{@temp}/#{username}_#{app}_repo -t php-5.3.2 -b")
    end
  end
end

Then /^they should all be accessible$/ do
  # Generate the 'product' of username / app combinations
  user_apps = @usernames.product(@apps)

  urls = {}
  # Hit the health check page for each app
  user_apps.each do |user_app|
    # Make sure to handle timeouts
    host = "#{user_app[1]}.#{user_app[0]}.#{$domain}"
    begin
      res = Net::HTTP.start(host, 80) do |http|
        http.read_timeout = 5
        http.get("/health_check.php")
      end
      code = res.code
    rescue Net::HTTPError
      code = -1
    end

    # Store the results
    urls[host] = code
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
