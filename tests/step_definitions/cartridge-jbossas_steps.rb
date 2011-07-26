$cartridge_root ||= "/usr/libexec/li/cartridges"
$jbossas_version = "jbossas-7.0"
$jbossas_cartridge = "#{$cartridge_root}/#{$jbossas_version}"
#$jbossas_common_conf_path = "#{$jbossas_cartridge}/info/configuration/etc/conf/httpd_nolog.conf"
$jbossas_hooks = "#{$jbossas_cartridge}/info/hooks"
$jbossas_config_path = "#{$jbossas_hooks}/configure"
# app_name namespace acct_name
$jbossas_config_format = "#{$jbossas_config_path} '%s' '%s' '%s'"
$jbossas_deconfig_path = "#{$jbossas_hooks}/deconfigure"
$jbossas_deconfig_format = "#{$jbossas_deconfig_path} '%s' '%s' '%s'"

$jbossas_start_path = "#{$jbossas_hooks}/start"
$jbossas_start_format = "#{$jbossas_start_path} '%s' '%s' '%s'"

$jbossas_stop_path = "#{$jbossas_hooks}/stop"
$jbossas_stop_format = "#{$jbossas_stop_path} '%s' '%s' '%s'"

$jbossas_status_path = "#{$jbossas_hooks}/status"
$jbossas_status_format = "#{$jbossas_status_path} '%s' '%s' '%s'"

When /^I configure a jbossas application$/ do
  account_name = @account['accountname']
  namespace = "ns1"
  app_name = "app1"
  @app = {
    'name' => app_name,
    'namespace' => namespace
  }
  command = $jbossas_config_format % [app_name, namespace, account_name]
  buffer = []
  exit_code = runcon command,  'unconfined_u', 'system_r', 'libra_initrc_t', buffer
  puts buffer[0]
  puts buffer[1]
  raise Exception.new "Error running #{command}: Exit code: #{exit_code}" if exit_code != 0
end

Given /^a new jbossas application$/ do
  account_name = @account['accountname']
  app_name = 'app1'
  namespace = 'ns1'
  @app = {
    'namespace' => namespace,
    'name' => app_name
  }
  command = $jbossas_config_format % [app_name, namespace, account_name]
  runcon command, 'unconfined_u', 'system_r', 'libra_initrc_t'
end

When /^I deconfigure the jbossas application$/ do
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']
  command = $jbossas_deconfig_format % [app_name, namespace, account_name]
  runcon command,  'unconfined_u', 'system_r', 'libra_initrc_t'
end

When /^I (start|stop|restart) the jbossas service$/ do |action|
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']

  command = "#{$jbossas_hooks}/%s %s %s %s" % [action, app_name, namespace, account_name]
  exit_status = runcon command, 'unconfined_u', 'system_r', 'libra_initrc_t'
  if exit_status != 0
    raise "Unable to %s for %s %s %s" % [fix_action, app_name, namespace, account_name]
  end
  sleep 5
end

Given /^the jbossas service is (running|stopped)$/ do |status|
  pending # express the regexp above with the code you wish you had
end

Then /^a jbossas application directory will( not)? exist$/ do |negate|
  acct_name = @account['accountname']
  app_name = @app['name']

  app_root = "#{$home_root}/#{acct_name}/#{app_name}"
  status = (File.exists? app_root and File.directory? app_root) 
  # TODO - need to check permissions and SELinux labels

  if not negate
    status.should be_true "#{app_root} does not exist or is not a directory"
  else
    status.should be_false "file #{app_root} exists and is a directory.  it should not"
  end
end

Then /^the jbossas application directory tree will( not)? be populated$/ do |negate|
  # This directory should contain specfic elements:
  
  acct_name = @account['accountname']
  app_name = @app['name']

  app_root = "#{$home_root}/#{acct_name}/#{app_name}"

  file_list =  ['repo', 'run', 'tmp', 'data', $jbossas_version, 
                "#{$jbossas_version}/bin",  
                "#{$jbossas_version}/standalone/configuration"
               ]

  file_list.each do |file_name| 
    file_path = app_root + "/" + file_name
    file_exists = File.exists? file_path
    if not negate
      file_exists.should be_true "file #{file_path} does not exist"
    else
      file_exists.should be_false "file #{file_path} exists, and should not"
    end
  end
end

Then /^the jbossas server and module files will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the jbossas server configuration files will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the jbossas standalone scripts will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a jbossas git repo will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the jbossas git hooks will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a jbossas deployments directory will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a jbossas service startup script will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a jbossas source tree will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a jbossas application http proxy file will exist$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^a jbossas daemon will be running$/ do
  pending # express the regexp above with the code you wish you had
end
