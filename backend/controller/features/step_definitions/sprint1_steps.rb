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
  quit = false
  r_usernames = []

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
          username = get_unique_username(1, r_usernames)

          # Add it to the reserved list
          r_usernames << username
        end


        # Create the user
        begin
          run("/usr/bin/libra_create_customer -u #{username} -e nobody@example.com") if username
        rescue
          mutex.synchronize { failed = true }
        end

        mutex.synchronize do
          # Remove the username from the reserved list
          r_usernames.delete(username)
        end

        # Verify the user was created
        @@logger.info("Looking up user: #{username}")
        User.find(username).should_not be_nil
      end
    end
  end

  threads.each {|t| t.join }
end

When /^(\d+) applications of type '(.+)' are created per user$/ do |num_apps, framework|
  @apps = (num_apps.to_i).times.collect{|num| "app#{num}" }
  puts "Num apps #{num_apps}"
  puts "Framework #{framework}"
end

Then /^they should all be accessible$/ do

end
