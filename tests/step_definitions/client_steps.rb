Given /^an accepted node$/ do
  accept_node = "/usr/bin/rhc-accept-node"
  File.exists?(accept_node).should be_true

  pass = `sudo #{accept_node}`.chomp
  $?.exitstatus.should be(0)
  pass.should == "PASS"
end

Given /^the libra client tools$/ do
  File.exists?($create_app_script).should be_true
  File.exists?($create_domain_script).should be_true
  File.exists?($client_config).should be_true
  File.exists?($ctl_app_script).should be_true
end
