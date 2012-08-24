Given /^an accepted node$/ do
  accept_node = "/usr/bin/rhc-accept-node"
  assert_file_exists accept_node

  num_tries = 10
  (1..num_tries).each do |i|
    begin
      pass = `sudo #{accept_node} 2>&1`.chomp  
      exit_status = $?.exitstatus
      
      if i == num_tries
        puts pass if pass != "PASS"
        puts "Exit status = #{exit_status}" if exit_status != 0
      end
    
      exit_status.should be(0)
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
  assert_file_exists $create_app_script
  assert_file_exists $create_domain_script
  assert_file_exists $client_config
  assert_file_exists $ctl_app_script

  assert_file_exists $rhc_app_script
  assert_file_exists $rhc_domain_script
  assert_file_exists $rhc_sshkey_script
end
