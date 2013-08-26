require 'rubygems'
require 'parseconfig'
require 'mcollective'

include MCollective::RPC
options = MCollective::Util.default_options

Given /^a district (.*) is active$/ do |uuid|
  # Clean up anything left over
  FileUtils.rm_f "/var/lib/openshift/.settings/district.info"
  mc = rpcclient("openshift", {:options => options})
  reply = mc.set_district(:uuid => uuid, :active => true)
  reply[0][:data][:exitcode].should be == 0
end

Then /^the file (.*) is active for district (.*)$/ do |file, uuid|
  config = ParseConfig.new  "/var/lib/openshift/.settings/district.info"

  config['uuid'].should == uuid
  config['active'].should == "true"
end

Then /^the file (.*) does( not)? exist$/ do |file, negate|
  if negate
    refute_file_exist file
  else
    assert_file_exist file
  end
end

Then /^remove file (.*)/ do |file|
  FileUtils.rm_f file
end
