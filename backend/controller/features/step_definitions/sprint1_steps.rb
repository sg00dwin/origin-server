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

  processes = []

  # Limit loop on the number of users established in a previous step
  @usernames.each_with_index do |data, index|
    # Get a unique username to create in the forked process
    # and add it to the list of reserved usernames to avoid
    # race conditions of duplicate users
    username = get_unique_username(1, @usernames)
    @usernames[index] = username

    # Create the users in subprocesses
    # Count the current sub processes
    # if at max, wait for some to finish and keep going

    processes << fork do
      # Create the user and the apps
      run("#{$create_user_script} -u #{username} -e #{$email}")
      @apps.each do |app|
        run("#{$create_app_script} -u #{username} -a #{app} -r #{$temp}/#{username}_#{app}_repo -t php-5.3.2 -b -d")
      end
    end

    # Wait for some process to complete if necessary
    Timeout::timeout(300) do
      pid = processes.shift
      Process.wait(pid)
      $logger.error("Process #{pid} failed") if $?.exitstatus != 0
    end if processes.length >= @max_processes

    # sleep a little to randomize forks
    sleep rand
  end

  # Wait for the remaining processes
  processes.reverse.each do |pid|
    Timeout::timeout(300) do
      Process.wait(pid)
      $logger.error("Process #{pid} failed") if $?.exitstatus != 0
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
      $logger.info("Checking host #{host}")
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


Then /^they should be able to be changed$/ do
  # Generate the 'product' of username / app combinations
  user_apps = @usernames.product(@apps)

  # Make a change and push it
  urls = {}
  user_apps.each do |user_app|
    $logger.info("Changing to dir=#{$temp}/#{user_app[0]}_#{user_app[1]}_repo")
    Dir.chdir("#{$temp}/#{user_app[0]}_#{user_app[1]}_repo")
    system('sed -i "/<h1>/a<p>making a change</p>" index.php')
    #wc = %x[cat index.php | wc -m --chars].chomp.to_i;
    $logger.info("git commit -a -m 'Testing a commit'")
    system("git commit -a -m 'Testing a commit'")
    $logger.info('git push libra master')
    system('git push libra master')
    # Make sure to handle timeouts
    host = "#{user_app[1]}.#{user_app[0]}.#{$domain}"
    begin
      req = Net::HTTP::Get.new('/index.php')
      $logger.info("host= #{host}")    
      res = Net::HTTP.start(host, 80) do |http|
        #http.read_timeout = 5
        http.request(req)
      end
      code = res.code
      file = File.open("index.php", "rb")
      contents = file.read
      #validate the change made it up
      res.body.should == contents  
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
