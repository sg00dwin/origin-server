# Controller cartridge command paths
$cartridge_root ||= "/usr/libexec/stickshift/cartridges"
$php_cartridge = "#{$cartridge_root}/php-5.3"
$php_common_conf_path = "#{$php_cartridge}/info/configuration/etc/conf/httpd_nolog.conf"
$php_hooks = "#{$php_cartridge}/info/hooks"
$php_config_path = "#{$php_hooks}/configure"
# app_name namespace acct_name
$php_config_format = "#{$php_config_path} '%s' '%s' '%s'"
$php_deconfig_path = "#{$php_hooks}/deconfigure"
$php_deconfig_format = "#{$php_deconfig_path} '%s' '%s' '%s'"

$php_start_path = "#{$php_hooks}/start"
$php_start_format = "#{$php_start_path} '%s' '%s' '%s'"

$php_stop_path = "#{$php_hooks}/stop"
$php_stop_format = "#{$php_stop_path} '%s' '%s' '%s'"

$php_status_path = "#{$php_hooks}/status"
$php_status_format = "#{$php_status_path} '%s' '%s' '%s'"

$libra_httpd_conf_d ||= "/var/lib/stickshift/.httpd.d/"

Given /^a new php_idler application$/ do
  account_name = @account['accountname']
  namespace = @account['namespace']
  app_name = @account['appnames'][0]
  @app = {
    'namespace' => namespace,
    'name' => app_name
  }
  command = $php_config_format % [app_name, namespace, account_name]
  exit_code = runcon command, $selinux_user, $selinux_role, $selinux_type, nil, 10
  raise "Non zero exit code when creating php application: #{exit_code}" unless exit_code == 0
end

Then /^the php application health\-check will( not)? be successful$/ do | negate |
  good_status = negate ? 1 : 0

  command = "/usr/bin/curl -L -H 'Host: #{@app['name']}-#{@app['namespace']}.dev.rhcloud.com' -s http://localhost/health_check.php | /bin/grep -e '^1$'"

  # This command causes curl to hit the app, causing restorer to turn it back
  # on and redirect.  Curl then follows that redirect.
  retries = 60
  while 0 < retries
    exit_code = run command
    break if exit_code == good_status
    sleep 1
    retries -= 1
    $logger.info("Waiting for httpd graceful to finish. Retries left: #{retries}")
  end

  exit_code.should == good_status
end

When /^I idle the php application$/ do
  account_name = @account['accountname']
  exit_code = run("/usr/bin/rhc-idler -u #{@account['accountname']}")
  raise "Non zero exit code when idling php application: #{exit_code}" unless exit_code == 0
end

Then /^record the active capacity$/ do
  @app['active_capacity'] = `facter | grep active_capacity`.split(' ')[2].to_f
end

Then /^the active capacity has been reduced$/ do
   current_capacity = `facter | grep active_capacity`.split(' ')[2].to_f
   @app['active_capacity'].should be > current_capacity
end
