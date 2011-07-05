# Controller cartridge command paths
$php_cartridge = "#{$cartridge_root}/php-5.3"
$php_hooks = "#{$php_cartridge}/info/hooks"
$php_config_path = "#{$php_hooks}/configure"
# app_name namespace acct_name
$php_config_format = "#{$php_config_path} '%s' '%s' '%s'"
$php_deconfig_path = "#{$php_hooks}/deconfigure"
# app_name namespace acct_name
$php_deconfig_format = "#{$php_deconfig_path} -c '%s'"

When /^I configure a PHP application$/ do
  # generate a random app_name and namespace, and add them to @apps['acct_name']
  pending # express the regexp above with the code you wish you had
end

Then /^a php application http proxy file will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a php application git repo will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a php application source tree will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a php application httpd will be running$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^a new PHP application$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I deconfigure the PHP application$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a php application http proxy file will not exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a php application git repo will not exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a php application source tree will not exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a php application httpd will not be running$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^the php application is stopped$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I start the PHP application$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^the php application is running$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I stop the PHP application$/ do
  pending # express the regexp above with the code you wish you had
end
