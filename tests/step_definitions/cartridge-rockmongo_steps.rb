require 'fileutils'

$rockmongo_version = "1.1"
$rockmongo_cart_root = "/usr/libexec/stickshift/cartridges/embedded/rockmongo-#{$rockmongo_version}"
$rockmongo_hooks = $rockmongo_cart_root + "/info/hooks"
$rockmongo_config = $rockmongo_hooks + "/configure"
$rockmongo_config_format = "#{$rockmongo_config} %s %s %s"
$rockmongo_deconfig = $rockmongo_hooks + "/deconfigure"
$rockmongo_deconfig_format = "#{$rockmongo_deconfig} %s %s %s"
$rockmongo_proc_regex = /httpd -C Include .*rockmongo/

Given /^a new rockmongo$/ do
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']
  command = $rockmongo_config_format % [app_name, namespace, account_name]

  outbuf = []
  exit_code = runcon command,  $selinux_user, $selinux_role, $selinux_type, outbuf

  if exit_code != 0
    raise "Error running #{command}: returned #{exit_code}"
  end
end

Given /^rockmongo is (running|stopped)$/ do | status |
  action = status == "running" ? "start" : "stop"

  acct_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']
  daemon_name = 'httpd'

  command = "#{$rockmongo_hooks}/#{action} #{app_name} #{namespace} #{acct_name}"

  num_daemons = num_procs_like acct_name, $rockmongo_proc_regex
  outbuf = []

  case action
  when 'start'
    if num_daemons == 0
      runcon command,  $selinux_user, $selinux_role, $selinux_type, outbuf
    end
    exit_test = lambda { |tval| tval > 0 }
  when 'stop'
    if num_daemons > 0
      runcon command,  $selinux_user, $selinux_role, $selinux_type, outbuf
    end
    exit_test = lambda { |tval| tval == 0 }
  # else
  #   raise an exception
  end

  # now loop until it's true
  max_tries = 10
  poll_rate = 3
  tries = 0
  num_daemons = num_procs_like acct_name, $rockmongo_proc_regex
  while (not exit_test.call(num_daemons) and tries < max_tries)
    tries += 1
    sleep poll_rate
    num_daemons = num_procs_like acct_name, $rockmongo_proc_regex
  end
end

When /^I configure rockmongo$/ do
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']
  command = $rockmongo_config_format % [app_name, namespace, account_name]

  outbuf = []
  exit_code = runcon command,  $selinux_user, $selinux_role, $selinux_type, outbuf

  if exit_code != 0
    raise "Error running #{command}: returned #{exit_code}"
  end
end

When /^I deconfigure rockmongo$/ do
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']
  command = $rockmongo_deconfig_format % [app_name, namespace, account_name]
  exit_code = runcon command,  $selinux_user, $selinux_role, $selinux_type
  if exit_code != 0
    raise "Command failed with exit code #{exit_code}"
  end
end

When /^I (start|stop|restart) rockmongo$/ do |action|
  acct_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']

  rockmongo_user_root = "#{$home_root}/#{acct_name}/rockmongo-#{$rockmongo_version}"

  outbuf = []
  command = "#{$rockmongo_hooks}/#{action} #{app_name} #{namespace} #{acct_name}"
  exit_code = runcon command,  $selinux_user, $selinux_role, $selinux_type, outbuf

  if exit_code != 0
    raise "Command failed with exit code #{exit_code}"
  end
end

Then /^a rockmongo http proxy file will( not)? exist$/ do | negate |
  acct_name = @account['accountname']
  app_name = @app['name']
  namespace = @app['namespace']

  conf_file_name = "#{acct_name}_#{namespace}_#{app_name}/rockmongo-#{$rockmongo_version}.conf"
  conf_file_path = "#{$libra_httpd_conf_d}/#{conf_file_name}"

  if not negate
    File.exists?(conf_file_path).should be_true
  else
    File.exists?(conf_file_path).should be_false
  end
end

Then /^a rockmongo httpd will( not)? be running$/ do | negate |
  acct_name = @account['accountname']
  acct_uid = @account['uid']
  app_name = @app['name']

  max_tries = 20
  poll_rate = 3
  exit_test = negate ? lambda { |tval| tval == 0 } : lambda { |tval| tval > 0 }

  tries = 0
  num_httpds = num_procs_like acct_name, $rockmongo_proc_regex
  while (not exit_test.call(num_httpds) and tries < max_tries)
    tries += 1
    sleep poll_rate
  end

  if not negate
    num_httpds.should be > 0
  else
    num_httpds.should be == 0
  end
end

Then /^the rockmongo directory will( not)? exist$/ do | negate |
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']

  rockmongo_user_root = "#{$home_root}/#{account_name}/rockmongo-#{$rockmongo_version}"
  begin
    rockmongo_dir = Dir.new rockmongo_user_root
  rescue Errno::ENOENT
    rockmongo_dir = nil
  end

  unless negate
    rockmongo_dir.should be_a(Dir)
  else
    rockmongo_dir.should be_nil
  end
end

Then /^rockmongo log files will( not)? exist$/ do | negate |
  acct_name = @account['accountname']
  acct_uid = @account['uid']
  app_name = @app['name']
  log_dir_path = "#{$home_root}/#{acct_name}/rockmongo-#{$rockmongo_version}/logs"
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

Then /^the rockmongo control script will( not)? exist$/ do | negate |
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']

  rockmongo_user_root = "#{$home_root}/#{account_name}/rockmongo-#{$rockmongo_version}"
  rockmongo_startup_file = "#{rockmongo_user_root}/#{app_name}_rockmongo_ctl.sh"

  begin
    startfile = File.new rockmongo_startup_file
  rescue Errno::ENOENT
    startfile = nil
  end

  unless negate
    startfile.should be_a(File)
  else
    startfile.should be_nil
  end
end

# Pulls the reverse proxy destination from the proxy conf file and ensures
# the path it forwards to is accessible via the external IP of the instance.
Then /^the rockmongo web console url will be accessible$/ do
  acct_name = @account['accountname']
  app_name = @app['name']
  namespace = @app['namespace']

  conf_file_name = "#{acct_name}_#{namespace}_#{app_name}/rockmongo-#{$rockmongo_version}.conf"
  conf_file_path = "#{$libra_httpd_conf_d}/#{conf_file_name}"

  # The URL segment for the cart lives in the proxy conf
  cart_path = `/bin/awk '/ProxyPassReverse/ {printf "%s", $2;}' #{conf_file_path}`

  # Assemble a test URL for the cart. This seems pretty cheesy. I could query the root,
  # but we'll get a 302 redirect, and I'm not sure if that's a good test.
  conf_url = "https://127.0.0.1#{cart_path}/js/collection.js"

  # Strip just the status code out of the response. Set the Host header to 
  # simulate an external request, exercising the front-end httpd proxy.
  res = `/usr/bin/curl -k -w %{http_code} -s -o /dev/null -H 'Host: #{app_name}-#{namespace}.dev.rhcloud.com' #{conf_url}`

  raise "Expected 200 response from #{conf_url}, got #{res}" unless res == "200"
end
