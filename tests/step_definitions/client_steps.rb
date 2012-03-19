Given /^an accepted node$/ do
  accept_node = "/usr/bin/rhc-accept-node"
  File.exists?(accept_node).should be_true
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
  File.exists?($create_app_script).should be_true
  File.exists?($create_domain_script).should be_true
  File.exists?($client_config).should be_true
  File.exists?($ctl_app_script).should be_true

  File.exists?($rhc_app_script).should be_true
  File.exists?($rhc_domain_script).should be_true
  File.exists?($rhc_sshkey_script).should be_true
end
