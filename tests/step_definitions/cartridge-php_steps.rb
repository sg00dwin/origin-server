# Controller cartridge command paths
$cartridge_root ||= "/usr/libexec/li/cartridges"
$php_cartridge = "#{$cartridge_root}/php-5.3"
$php_hooks = "#{$php_cartridge}/info/hooks"
$php_config_path = "#{$php_hooks}/configure"
# app_name namespace acct_name
$php_config_format = "#{$php_config_path} '%s' '%s' '%s'"
$php_deconfig_path = "#{$php_hooks}/deconfigure"
# app_name namespace acct_name
$php_deconfig_format = "#{$php_deconfig_path} -c '%s'"
$libra_httpd_conf_d ||= "/etc/httpd/conf.d/libra"

When /^I configure a PHP application$/ do
  account_name = @account['accountname']
  namespace = "ns1"
  app_name = "app1"
  @app = {
    'name' => app_name,
    'namespace' => namespace
  }
  command = $php_config_format % [app_name, namespace, account_name]
  puts "running '#{command}'"
  runcon command,  'unconfined_u', 'system_r', 'libra_initrc_t'
end

Then /^a php application http proxy file will exist$/ do
  acct_name = @account['accountname']
  app_name = @app['name']
  namespace = @app['namespace']

  conf_file_name = "#{@acct_name}_#{namespace}_#{app_name}.conf"
  conf_file_path = "#{$libra_httpd_conf_d}/#{conf_file_name}"
  
  File.exists? conf_file_path
end

Then /^a php application git repo will exist$/ do
  acct_name = @account['accountname']
  app_name = @app['name']

  git_repo = "#$libra_dir/#acct_name/git/#{app_name}.git"
  File.exists? git_repo and File.directory? git_repo
  # TODO - need to check permissions and SELinux labels
end

Then /^a php application source tree will exist$/ do
  acct_name = @account['accountname']
  app_name = @app['name']

  app_root = "#$libra_dir/#acct_name/#{app_name}"
  File.exists? app_root and File.directory? app_root
  # TODO - need to check permissions and SELinux labels
end

Then /^a php application httpd will be running$/ do
  acct_name = @account['accountname']
  acct_uid = @account['uid']
  app_name = @app['name']

  # Find out how many should be running: min/max

  # find all processes for this UID

  # count the httpds

  # check that each httpd has a rotatelogs

  pending # express the regexp above with the code you wish you had
end

Then /^php application log files will exist$/ do

end

Given /^a new PHP application$/ do
  account_name = @account['account_name']
  namespace = "ns1"
  app_name = "app1"
  command = $php_config_format % [app_name, namespace, account_name]
  run command
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
