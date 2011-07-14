# step descriptions for MySQL cartridge behavior.

$mysql_version = "5.1"
$mysql_cart_root = "/usr/libexec/li/cartridges/embedded/mysql-#{$mysql_version}"
$mysql_hooks = $mysql_cart_root + "/info/hooks"
$mysql_config = $mysql_hooks + "/configure"
$mysql_config_format = "#{$mysql_config} %s %s %s"
$mysql_deconfig = $mysql_hooks + "/deconfigure"
$mysql_deconfig_format = "#{$mysql_deconfig} %s %s %s"

When /^I configure a mysql database$/ do
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']
  command = $mysql_config_format % [app_name, namespace, account_name]
  runcon command,  'unconfined_u', 'system_r', 'libra_initrc_t'
end

When /^I deconfigure the mysql database$/ do
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']
  command = $mysql_deconfig_format % [app_name, namespace, account_name]
  runcon command,  'unconfined_u', 'system_r', 'libra_initrc_t'
end

Then /^the mysql directory will( not)? exist$/ do |negate|
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']

  mysql_user_root = "#{$home_root}/#{account_name}/mysql-#{$mysql_version}"
  begin
    mysql_dir = Dir.new mysql_user_root
    puts "Found the directory: #{mysql_dir}"
  rescue Errno::ENOENT
    mysql_dir = nil
    puts "did not find the directory #{mysql_user_root}"
  end

  unless negate
    mysql_dir.should be_a(Dir)
  else
    mysql_dir.should be_nil
  end
end

Then /^the mysql configuration file will( not)? exist$/ do |negate|
  pending # express the regexp above with the code you wish you had
end

Then /^the mysql database will( not)? +exist$/ do |negate|
  pending # express the regexp above with the code you wish you had
end

Then /^the mysql control script will( not)? exist$/ do |negate|
  pending # express the regexp above with the code you wish you had
end

Then /^the mysql daemon will be (running|stopped)$/ do |state|
  pending # express the regexp above with the code you wish you had
end

Then /^the admin user will have access$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^a new mysql database$/ do
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']
  command = $mysql_config_format % [app_name, namespace, account_name]
  runcon command,  'unconfined_u', 'system_r', 'libra_initrc_t'
end

Given /^the mysql database is (running|stopped)$/ do |state|
  pending # express the regexp above with the code you wish you had
end

When /^I (start|stop|restart) the mysql database$/ do |action|
  pending # express the regexp above with the code you wish you had
end


