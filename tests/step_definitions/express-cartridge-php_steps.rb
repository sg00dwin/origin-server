# Controller cartridge command paths
$cartridge_root ||= "/usr/libexec/stickshift/cartridges"
$php_cartridge = "#{$cartridge_root}/php-5.3"
$php_hooks = "#{$php_cartridge}/info/hooks"

When /^I (expose-port|conceal-port) the php application$/ do |action|
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']

  command = "#{$php_hooks}/%s %s %s %s" % [action, app_name, namespace, account_name]
  exit_status = runcon command, $selinux_user, $selinux_role, $selinux_type, nil, 10
  if exit_status != 0
    raise "Unable to %s for %s %s %s" % [action, app_name, namespace, account_name]
  end
end

Then /^the php application will( not)? be exposed$/ do | negate |
  account_name = @account['accountname']
  namespace = @app['namespace']
  app_name = @app['name']

  good_status = negate ? 1 : 0

  command = "#{$php_hooks}/show-port %s %s %s | /bin/grep -q PROXY_PORT" % [app_name, namespace, account_name]
  exit_status = runcon command, $selinux_user, $selinux_role, $selinux_type
  exit_status.should == good_status
end

Then /^the php file permissions are correct/ do
  gear_uuid = @account['accountname']
  app_home = "/var/lib/stickshift/#{gear_uuid}"
  uid = Etc.getpwnam(gear_uuid).uid
  gid = Etc.getpwnam(gear_uuid).gid
  mcs = libra_mcs_level(uid)
  # Configure files (relative to app_home)
  configure_files = { "#{@app['name']}" => ['root', 'root', '40755', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                     "php-5.3/" => ['root', 'root', '40755', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "php-5.3/#{@app['name']}_ctl.sh" => ['root', 'root', '100755', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    ".pearrc" => ['root', 'root', '100644', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "php-5.3/conf/" => ['root', 'root', '40755', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "php-5.3/conf/php.ini" => ['root', 'root', '100644', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "php-5.3/conf/magic" => ['root', 'root', '100644', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "php-5.3/conf.d/" => ['root', 'root', '40755', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "php-5.3/conf.d/stickshift.conf" => ['root', 'root', '100644', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "app-root/data/" => [gear_uuid, gear_uuid, '40755', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "#{@app['name']}/logs/" => [gear_uuid, gear_uuid, '40755', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "php-5.3/phplib/pear/" => [gear_uuid, gear_uuid, '40755', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "app-root/data/" => [gear_uuid, gear_uuid, '40750', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "app-root/repo/" => [gear_uuid, gear_uuid, '40750', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "php-5.3/run/" => [gear_uuid, gear_uuid, '40755', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "php-5.3/run/httpd.pid" => [gear_uuid, gear_uuid, '100644', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "app-root/repo/php/index.php" => [gear_uuid, gear_uuid, '100664', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "php-5.3/sessions/" => [gear_uuid, gear_uuid, '40755', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"],
                    "php-5.3/tmp/" => [gear_uuid, gear_uuid, '40755', "unconfined_u:object_r:libra_var_lib_t:#{mcs}"]
                    }
  configure_files.each do | file, permissions |
    raise "Invalid permissions for #{file}" unless mode?("#{app_home}/#{file}", permissions[2])
    raise "Invalid context for #{file}" unless context?("#{app_home}/#{file}", permissions[3])
    target_uid = Etc.getpwnam(permissions[0]).uid.to_i
    target_gid = Etc.getgrnam(permissions[1]).gid.to_i
    raise "Invalid ownership for #{file}" unless owner?("#{app_home}/#{file}", target_uid, target_gid)
  end
end

