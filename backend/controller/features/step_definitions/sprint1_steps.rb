require 'thread'

Given /^the libra client tools$/ do
  File.exists?("/usr/bin/libra_create_app").should be_true
  File.exists?("/usr/bin/libra_create_customer").should be_true
  File.exists?("/etc/libra/client.conf").should be_true
end

When /^(\d+) new users are created$/ do |num_users|
  mutex = Mutex.new

  runs = 0
  failed = false
  @usernames = []

  # Create users with multiple threads
  threads = @@THREADS.times.collect do
    Thread.new do
      loop do
        username = nil
        mutex.synchronize do
          # Increment the number of runs
          runs += 1

          # Break if thread has failed or we hit the limit
          Thread.exit if failed or runs >= num_users.to_i

          # Safely get the next username
          username = get_unique_username(1, @usernames)
          @usernames << username
        end


        # Create the user
        begin
          run("/usr/bin/libra_create_customer -u #{username} -e nobody@example.com")
        rescue
          mutex.synchronize { failed = true }
        end

        # Verify the user was created
        @@logger.info("Verifying user: #{username}")
        User.find(username).should_not be_nil
      end
    end
  end

  threads.each {|t| t.join }
end

When /^(\d+) applications of type '(.+)' are created per user$/ do |num_apps, framework|
  @apps = (num_apps.to_i).times.collect{|num| "app#{num}" }

  # Generate the 'product' of username / app combinations
  @user_apps = @usernames.product(@apps)

  mutex = Mutex.new
  failed = false

  # Create users with multiple threads
  threads = @@THREADS.times.collect do
    Thread.new do
      loop do
        username = nil
        app = nil
        mutex.synchronize do
          # Safely pop a combination to process
          result = @user_apps.pop

          # Break if thread has failed or we hit the limit
          Thread.exit if failed or !result

          # Parse out the username and app name
          username = result[0]
          app = result[1]
        end

        # Create the application
        begin
          run("/usr/bin/libra_create_app -u #{username} -a #{app} -r /tmp/#{username}_#{app}_repo -t php-5.3.2 -b")
        rescue
          mutex.synchronize { failed = true }
        end

        # Verify the user was created
        @@logger.info("Verifying app creation: #{username} / #{app}")
        User.find(username).apps.index(app).should_not be_nil
      end
    end

    # Pause between spinning up threads
    #puts "Sleeping"
    #sleep 5
  end

  threads.each {|t| t.join }
end

Then /^they should all be accessible$/ do

end
