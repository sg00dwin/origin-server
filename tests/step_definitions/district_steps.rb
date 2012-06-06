
Given /^a district (.*) is active$/ do |uuid|
  # Clean up anything left over
  FileUtils.rm_f "/var/lib/stickshift/district.conf"
  exit_code = run "mc rpc libra set_district uuid=#{uuid} active='true'"
  exit_code.should be == 0
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
