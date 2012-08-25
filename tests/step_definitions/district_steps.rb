require 'rubygems'
require 'parseconfig'
require 'mcollective'

include MCollective::RPC
options = MCollective::Util.default_options

Given /^a district (.*) is active$/ do |uuid|
  # Clean up anything left over
  FileUtils.rm_f "/var/lib/stickshift/.settings/district.info"
  mc = rpcclient("stickshift", {:options => options})
  reply = mc.set_district(:uuid => uuid, :active => 'true')
  reply[0][:data][:exitcode].should be == 0
end

Then /^the file (.*) is active for district (.*)$/ do |file, uuid|
  config = ParseConfig.new  "/var/lib/stickshift/.settings/district.info"

  config.get_value('uuid').should == uuid
  config.get_value('active').should == "true"
end

Then /^the file (.*) does( not)? exist$/ do |file, negate|
  if negate
    assert_file_not_exists file
  else
    assert_file_exists file
  end
end

Then /^remove file (.*)/ do |file|
  FileUtils.rm_f file
end
