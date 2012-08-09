Then /^the php application health\-check will( not)? be successful$/ do | negate |
  expected_code = negate ? 0 : 1

  # Use curl to hit the app, causing restorer to turn it back
  # on and redirect.  Curl then follows that redirect.
  host = "#{@app.name}-#{@account.name}.dev.rhcloud.com"
  command = "/usr/bin/curl -L -k -H 'Host: #{host}' -s http://localhost/health_check.php | /bin/grep -e '^1$'"
  exit_code = run command
  StickShift::timeout(60) do
    while exit_code != expected_code
      exit_code = run command
      $logger.info("Idler waiting for httpd graceful to finish. #{host}")
      sleep 1
    end
  end
  exit_code.should == expected_code
end

When /^I idle the application$/ do
  cmd = "/usr/bin/rhc-idler -u #{@gear.uuid}" 
  exit_code = run cmd
  assert_equal 0, exit_code, "Failed to idle php application running #{cmd}"
end

Then /^I record the active capacity$/ do
  @active_capacity = `facter active_capacity`.to_f
  @active_capacity.should be > 0.0
end

Then /^the active capacity has been reduced$/ do
   current_capacity = `facter active_capacity`.to_f
   current_capacity.should be > 0.0
   @active_capacity.should be > current_capacity
end
