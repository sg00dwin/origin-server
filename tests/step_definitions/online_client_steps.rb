Given /^an accepted node$/ do
  accept_node = "/usr/sbin/oo-accept-node"
  assert_file_exist accept_node

  num_tries = 10
  (1..num_tries).each do |i|
    begin
      pass = `sudo #{accept_node} 2>&1`.chomp  
      exit_status = $?.exitstatus
      
      if i == num_tries
        puts pass if pass != "PASS"
        puts "Exit status = #{exit_status}" if exit_status != 0
      end
    
      exit_status.should eq(0)
      pass.should == "PASS"
      break
    rescue Exception => e
      if i == num_tries
        raise
      end
    end
  end
end

Given /^the libra client tools$/ do
  assert_file_exist $client_config
  assert_file_exist $rhc_script
end
