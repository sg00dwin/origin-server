# Controller cartridge command paths
$cartridge_root ||= "/usr/libexec/li/cartridges"
$php_cartridge = "#{$cartridge_root}/php-5.3"
$php_common_conf_path = "#{$php_cartridge}/info/configuration/etc/conf/httpd_nolog.conf"
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
  #puts "running '#{command}'"
  runcon command,  'unconfined_u', 'system_r', 'libra_initrc_t'
end

Then /^a php application http proxy file will( not)? exist$/ do | negate |
  acct_name = @account['accountname']
  app_name = @app['name']
  namespace = @app['namespace']

  conf_file_name = "#{@acct_name}_#{namespace}_#{app_name}.conf"
  conf_file_path = "#{$libra_httpd_conf_d}/#{conf_file_name}"
  
  File.exists?(conf_file_path) ^ negate
end

Then /^a php application git repo will( not)? exist$/ do | negate |
  acct_name = @account['accountname']
  app_name = @app['name']

  git_repo = "#$libra_dir/#acct_name/git/#{app_name}.git"
  (File.exists? git_repo and File.directory? git_repo) ^ negate
  # TODO - need to check permissions and SELinux labels
end

Then /^a php application source tree will( not)? exist$/ do | negate |
  acct_name = @account['accountname']
  app_name = @app['name']

  app_root = "#$libra_dir/#acct_name/#{app_name}"
  (File.exists? app_root and File.directory? app_root) ^ negate
  # TODO - need to check permissions and SELinux labels
end

Then /^a php application httpd will( not)? be running$/ do | negate |
  acct_name = @account['accountname']
  acct_uid = @account['uid']
  app_name = @app['name']

  ps_pattern = /^(\d+)\s+(\S+)$/
  command = "ps --no-headers -o pid,comm -u #{acct_name}"
  pid, stdin, stdout, stderr = Open4::popen4(command)

  stdin.close
  ignored, status = Process::waitpid2 pid
  exit_code = status.exitstatus

  # sleep?

  http_daemons = stdout.collect { |line|
    match = line.match(ps_pattern)
    match and (match[1] if match[2] == 'httpd')
  }.compact!

  http_daemons and puts "httpd PIDs = #{http_daemons.join(',')}"

  (http_daemons and http_daemons.size > 0) ^ negate
end

Then /^php application log files will( not)? exist$/ do | negate |
  acct_name = @account['accountname']
  acct_uid = @account['uid']
  app_name = @app['name']
  log_dir_path = "#$libra_dir/#acct_name/#app_name/logs"

  begin
    log_dir = Dir.new log_dir_path
    (log_dir.count > 2) ^ negate
  rescue
    false ^ negate
  end
end

Given /^a new PHP application$/ do
  account_name = @account['account_name']
  app_name = 'app1'
  namespace = 'ns1'
  @app = {
    'namespace' => namespace,
    'name' => app_name
  }
  command = $php_config_format % [app_name, namespace, account_name]
  run command
end

When /^I deconfigure the PHP application$/ do
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']
  command = $php_deconfig_format % [app_name, namespace, account_name]
  #puts "running '#{command}'"
  runcon command,  'unconfined_u', 'system_r', 'libra_initrc_t'
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
