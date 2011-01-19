require 'net/http'
require 'uri'

Given /^the libra client tools$/ do
  File.exists?("/usr/bin/libra_create_app").should be_true
  File.exists?("/usr/bin/libra_create_customer").should be_true
  File.exists?("/etc/libra/client.conf").should be_true
end

When /^(\d+) new users are created$/ do |num_users|
  num_users = num_users.to_i

  # Come up with the list of usernames to create
  @usernames = []
  num_users.times do
    @usernames << get_unique_username(1, @usernames)
  end

  # Copy the array of usernames for the fork processing
  f_usernames = Array.new(@usernames)

  # Create the users in subprocesses
  loop do
    # Don't fork more than 10 processes at a time
    @@MAX_PROC.times do
      # Pop a username off the array
      username = f_usernames.pop

      # Process the username in a subprocess
      fork do
        @@logger.info("Fork Creating user #{username}")
        run("/usr/bin/libra_create_customer -u #{username} -e nobody@example.com")
      end if username
    end

    # Wait for the 10 processes to finish
    @@MAX_PROC.times do
      begin
        Process.wait
        exit_code = $?.exitstatus
        raise "User creation failed" if exit_code != 0
      rescue
        break
      end
    end

    # Break if we've processed all the usernames
    break if f_usernames.empty?
  end
end

When /^(\d+) applications of type '(.+)' are created per user$/ do |num_apps, framework|
  @apps = (num_apps.to_i).times.collect{|num| "app#{num}" }

  # Generate the 'product' of username / app combinations
  user_apps = @usernames.product(@apps)

  # Create the users in subprocesses
  loop do
    # Don't fork more than 10 processes at a time
    @@MAX_PROC.times do
      # Pop a user_app tuple off the array
      user_app = user_apps.pop

      # Process the username in a subprocess
      fork do
        # Parse the tuple
        username = user_app[0]
        app = user_app[1]

        # Create the application
        @@logger.info("Fork application creation #{username} / #{app}")
        run("/usr/bin/libra_create_app -u #{username} -a #{app} -r /tmp/#{username}_#{app}_repo -t php-5.3.2 -b")
      end if user_app
    end

    # Wait for the 10 processes to finish
    @@MAX_PROC.times do
      begin
        @@logger.info("Waiting for processes to complete")
        Process.wait
        exit_code = $?.exitstatus
        raise "App creation failed" if exit_code != 0
      rescue
        break
      end
    end

    # Break if we've processed all the usernames
    break if user_apps.empty?
  end
end

Then /^they should all be accessible$/ do
  # Generate the 'product' of username / app combinations
  user_apps = @usernames.product(@apps)

  # Hit the health check page for each app
  user_apps.each do |user_app|
    url = "http://#{user_app[1]}.#{user_app[0]}.libra.mmcgrath.net/php/health_check.php"
    Net::HTTP.get_response(URI.parse(url)).code.should == 200
  end
end
