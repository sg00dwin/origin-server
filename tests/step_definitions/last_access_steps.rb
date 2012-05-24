When /^the last access script is run$/ do
  run('/usr/bin/rhc-last-access')
end

Then /^the application last access file should be present$/ do
  @app.last_access_file_present?.should be_true
end

Then /^the application last access file should not be present$/ do
  @app.last_access_file_present?.should_not be_true
end
