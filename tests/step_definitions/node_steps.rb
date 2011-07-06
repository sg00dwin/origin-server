# 
# 
# Steps that can be used to check applications installed on a server (node)
#
#require 'etc'

require 'openshift'
require 'resolv'
include Libra
include Libra::Test::User
include Libra::Test::Util

# Controller cartridge command paths
$cartridge_root = '/usr/libexec/li/cartridges'
$controller_hooks = "#{$cartridge_root}/li-controller-0.1/info/hooks"
$controller_config_path = "#{$controller_hooks}/configure"
$controller_config_format = "#{$controller_config_path} -c '%s' -e '%s' -s '%s'"
$controller_deconfig_path = "#{$controller_hooks}/deconfigure"
$controller_deconfig_format = "#{$controller_deconfig_path} -c '%s'"
$home_root = "/var/lib/libra"
# --------------------------------------------------------------------------
# Account Checks
# --------------------------------------------------------------------------
# These must run after server_steps.rb: I create a <name> app for <framework>

# These depend on test data of this form:
#    And the following test data
#      | accountname                      | ssh_key_name | ssh_pub_key |
#      | 00112233445566778899aabbccdde000 | testkeyname0 | testkey0    |


# Convert a unix UID to a hex string suitable for use as a tc(1m) class value
def netclass uid
  "%04x" % uid
end

# copied from server-common/openshift/user.rb 20110630
def gen_small_uuid()
    # Put config option for rhlogin here so we can ignore uuid for dev environments
    %x[/usr/bin/uuidgen].gsub('-', '').strip
end

def parse_ssh_pub_key filename
  key_pattern = /^ssh-rsa (\S+) (\S+)\n$/
  key_string = File.open(filename, &:readline)  
  key_match = key_string.match key_pattern
  key_match[1..2] if key_match
end

Given /^a new guest account$/ do
  # call /usr/libexec/li/cartridges/li-controller-0.1/info/hooks/configure
  # generate a random account name and use the stock SSH keys
  # generate a random UUID and use the stock keys
  acctname = gen_small_uuid
  ssh_key_string, ssh_key_name = parse_ssh_pub_key $test_pub_key
  @account = {
    'accountname' => acctname,
    'ssh_key_string' => ssh_key_string,
    'ssh_key_name' => ssh_key_name
  }
  command = $controller_config_format % [acctname, ssh_key_name, ssh_key_string]

  run command
  # get and store the account UID's by name
  @account['uid'] = Etc.getpwnam(acctname).uid
end

Given /^the guest account has no application installed$/ do
  # Assume this is true
end

When /^I create a guest account$/ do
  # call /usr/libexec/li/cartridges  @table.hashes.each do |row|
  # generate a random account name and use the stock SSH keys
  # generate a random UUID and use the stock keys
  acctname = gen_small_uuid
  ssh_key_string, ssh_key_name = parse_ssh_pub_key $test_pub_key
  @account = {
      'accountname' => acctname,
      'ssh_key_string' => ssh_key_string,
      'ssh_key_name' => ssh_key_name
    }
  command = $controller_config_format % [acctname, ssh_key_name, ssh_key_string]
  run command
  # get and store the account UID's by name
  @account['uid'] = Etc.getpwnam(acctname).uid
end

When /^I delete the guest account$/ do
  # call /usr/libexec/li/cartridges  @table.hashes.each do |row|
  
  command = $controller_deconfig_format % [@account['accountname'],
                                           @account['ssh_key_string'],
                                           @account['ssh_key_name']]
  run command
end


Then /^an account password entry should( not)? exist$/ do |negate|
  # use @app['uuid'] for account name
  
  begin
    @pwent = Etc.getpwnam @account['accountname']
  rescue
    nil
  end

  if negate
    @pwent.should be_nil      
  else
    @pwent.should_not be_nil
  end
end

Then /^an account PAM limits file should( not)? exist$/ do |negate|
  limits_dir = '/etc/security/limits.d'
  @pamfile = File.exists? "#{limits_dir}/84-#{@account['accountname']}.conf"

  if negate
    @pamfile.should_not be_true
  else
    @pamfile.should be_true
  end
end

Then /^an HTTP proxy config file should( not)? exist$/ do |negate|

end

Then /^an account cgroup directory should( not)? exist$/ do |negate|
  cgroups_dir = '/cgroup/all/libra'
  @cgdir = File.directory? "#{cgroups_dir}/#{@account['accountname']}"

  if negate
    @cgdir.should_not be_true
  else
    @cgdir.should be_true
  end
end

Then /^an account home directory should( not)? exist$/ do |negate|
  @homedir = File.directory? "#{$home_root}/#{@account['accountname']}"
    
  if negate
    @homedir.should_not be_true
  else
    @homedir.should be_true
  end
end

Then /^the account home directory permissions should( not)? be correct$/ do |negate|
  pending
end

Then /^selinux labels on the account home directory should be correct$/ do
  homedir = "#{$home_root}/#{@account['accountname']}"
  @result = `restorecon -v -n #{homedir}`
  @result.should be == "" 
end

Then /^disk quotas on the account home directory should be correct$/ do

  # EXAMPLE

  # no such user
  # quota: user 00112233445566778899aabbccdde001 does not exist.

  # no quotas on user
  # Disk quotas for user root (uid 0): none

  # Disk quotas for user 00112233445566778899aabbccdde000 (uid 501): 
  #    Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
  #     /dev/xvde      24       0  131072               7       0   10000        


  @result = `quota -u #{@account['accountname']}`
    
  @result.should_not match /does not exist./
  @result.should_not match /: none\s*\n?/
  @result.should match /Filesystem  blocks   quota   limit   grace   files   quota   limit   grace/
end


Then /^a traffic control entry should( not)? exist$/ do |negate|
  acctname = @account['accountname']
  tc_format = 'tc -s class show dev eth0 classid 1:%s'
  tc_command = tc_format % (netclass @account['uid'])
  @result = `#{tc_command}`
  if negate
    @result.should be == ""
  else
    @result.should_not be == ""
  end
end

# Account home contents

# check the ssh keys?
Then /^the account should( not)? have an SSH key with the correct label$/ do |negate|
  ssh_format = '/var/lib/libra/%s/.ssh/authorized_keys'
  auth_keys_filename = ssh_format % @account['accountname']
  exists = File.exists? auth_keys_filename

  if negate
    exists.should be_false
  else
    exists.should be_true
  end
end
# 


# ===========================================================================
# Generic App Checks
# ===========================================================================

# ===========================================================================
# PHP App Checks
# ===========================================================================

# ===========================================================================
# WSGI App Checks
# ===========================================================================

# ===========================================================================
# Rack App Checks
# ===========================================================================
