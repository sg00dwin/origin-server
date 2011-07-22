# Controller cartridge command paths
$cartridge_root ||= "/usr/libexec/li/cartridges"
$wsgi_cartridge = "#{$cartridge_root}/wsgi-3.2"
$wsgi_common_conf_path = "#{$wsgi_cartridge}/info/configuration/etc/conf/httpd_nolog.conf"
$wsgi_hooks = "#{$wsgi_cartridge}/info/hooks"
$wsgi_config_path = "#{$wsgi_hooks}/configure"
# app_name namespace acct_name
$wsgi_config_format = "#{$wsgi_config_path} '%s' '%s' '%s'"
$wsgi_deconfig_path = "#{$wsgi_hooks}/deconfigure"
$wsgi_deconfig_format = "#{$wsgi_deconfig_path} '%s' '%s' '%s'"

$wsgi_start_path = "#{$wsgi_hooks}/start"
$wsgi_start_format = "#{$wsgi_start_path} '%s' '%s' '%s'"

$wsgi_stop_path = "#{$wsgi_hooks}/stop"
$wsgi_stop_format = "#{$wsgi_stop_path} '%s' '%s' '%s'"

$wsgi_status_path = "#{$wsgi_hooks}/status"
$wsgi_status_format = "#{$wsgi_status_path} '%s' '%s' '%s'"

$libra_httpd_conf_d ||= "/etc/httpd/conf.d/libra"

When /^I configure a wsgi application$/ do
  account_name = @account['accountname']
  namespace = "ns1"
  app_name = "app1"
  @app = {
    'name' => app_name,
    'namespace' => namespace
  }
  command = $wsgi_config_format % [app_name, namespace, account_name]
  runcon command,  'unconfined_u', 'system_r', 'libra_initrc_t'
end

Then /^a wsgi application http proxy file will( not)? exist$/ do | negate |
  acct_name = @account['accountname']
  app_name = @app['name']
  namespace = @app['namespace']

  conf_file_name = "#{acct_name}_#{namespace}_#{app_name}.conf"
  conf_file_path = "#{$libra_httpd_conf_d}/#{conf_file_name}"

  if not negate
    File.exists?(conf_file_path).should be_true
  else
    File.exists?(conf_file_path).should be_false
  end
end

Then /^a wsgi application git repo will( not)? exist$/ do | negate |
  acct_name = @account['accountname']
  app_name = @app['name']

  git_repo = "#{$home_root}/#{acct_name}/git/#{app_name}.git"
  status = (File.exists? git_repo and File.directory? git_repo)
  # TODO - need to check permissions and SELinux labels

  if not negate
    status.should be_true
  else
    status.should be_false
  end

end

Then /^a wsgi application source tree will( not)? exist$/ do | negate |
  acct_name = @account['accountname']
  app_name = @app['name']

  app_root = "#{$home_root}/#{acct_name}/#{app_name}"
  status = (File.exists? app_root and File.directory? app_root) 
  # TODO - need to check permissions and SELinux labels

  if not negate
    status.should be_true
  else
    status.should be_false
  end

end

Then /^a wsgi application httpd will( not)? be running$/ do | negate |
  acct_name = @account['accountname']
  acct_uid = @account['uid']
  app_name = @app['name']

  max_tries = 7
  poll_rate = 3
  exit_test = negate ? lambda { |tval| tval == 0 } : lambda { |tval| tval > 0 }
  
  tries = 0
  num_httpds = num_procs acct_name, 'httpd'
  while (not exit_test.call(num_httpds) and tries < max_tries)
    tries += 1
    sleep poll_rate
    found = exit_test.call num_httpds
  end

  if not negate
    num_httpds.should be > 0
  else
    num_httpds.should be == 0
  end
end

Then /^wsgi application log files will( not)? exist$/ do | negate |
  acct_name = @account['accountname']
  acct_uid = @account['uid']
  app_name = @app['name']
  log_dir_path = "#{$home_root}/#{acct_name}/#{app_name}/logs"
  begin
    log_dir = Dir.new log_dir_path
    status = (log_dir.count > 2)
  rescue
    status = false
  end

  if not negate
    status.should be_true
  else
    status.should be_false
  end

end

Given /^a new wsgi application$/ do
  account_name = @account['accountname']
  app_name = 'app1'
  namespace = 'ns1'
  @app = {
    'namespace' => namespace,
    'name' => app_name
  }
  command = $wsgi_config_format % [app_name, namespace, account_name]
  runcon command, 'unconfined_u', 'system_r', 'libra_initrc_t'
end

When /^I deconfigure the wsgi application$/ do
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']
  command = $wsgi_deconfig_format % [app_name, namespace, account_name]
  runcon command,  'unconfined_u', 'system_r', 'libra_initrc_t'
end

Given /^the wsgi application is (running|stopped)$/ do | start_state |
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']

  case start_state
  when 'running':
      fix_action = 'start'
      good_exit = 0
  when 'stopped':
      fix_action = 'stop'
      good_exit = 4
  end

  # check
  status_command = $wsgi_status_format %  [app_name, namespace, account_name]
  exit_status = runcon status_command, 'unconfined_u', 'system_r', 'libra_initrc_t'

  if exit_status != good_exit
    # fix it
    fix_command = "#{$wsgi_hooks}/%s %s %s %s" % [fix_action, app_name, namespace, account_name]
    exit_status = runcon fix_command, 'unconfined_u', 'system_r', 'libra_initrc_t'
    if exit_status != 0
      raise "Unable to %s for %s %s %s" % [fix_action, app_name, namespace, account_name]
    end
    sleep 5
    
    # check exit status
    exit_status = runcon status_command, 'unconfined_u', 'system_r', 'libra_initrc_t'
    if exit_status != good_exit
      raise "Received bad status after %s for %s %s %s" % [fix_action, app_name, namespace, account_name]
    end
  end
  # check again
end

When /^I (start|stop) the wsgi application$/ do |action|
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']

  command = "#{$wsgi_hooks}/%s %s %s %s" % [action, app_name, namespace, account_name]
  exit_status = runcon command, 'unconfined_u', 'system_r', 'libra_initrc_t'
  if exit_status != 0
    raise "Unable to %s for %s %s %s" % [fix_action, app_name, namespace, account_name]
  end
  sleep 5
end

Then /^the wsgi application will( not)? be running$/ do | negate |
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']

  good_status = negate ? 4 : 0

  command = "#{$wsgi_hooks}/status %s %s %s" % [app_name, namespace, account_name]
  exit_status = runcon command, 'unconfined_u', 'system_r', 'libra_initrc_t'
  exit_status.should == good_status
end

