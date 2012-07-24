require 'rubygems'
require 'parseconfig'

Given /^a district (.*) is active$/ do |uuid|
  # Clean up anything left over
  FileUtils.rm_f "/var/lib/stickshift/.settings/district.info"
  exit_code = run "mco rpc stickshift set_district uuid=#{uuid} active='true'"
  exit_code.should be == 0
end

Then /^the file (.*) is active for district (.*)$/ do |file, uuid|
  config = ParseConfig.new  "/var/lib/stickshift/.settings/district.info"

  config.get_value('uuid').should == uuid
  config.get_value('active').should == "true"
end

Then /^the file (.*) does( not)? exist$/ do |file, negate|
  if negate
    File.exist?(file).should be_false
  else
    File.exist?(file).should be_true
  end
end

Then /^remove file (.*)/ do |file|
  FileUtils.rm_f file
end
