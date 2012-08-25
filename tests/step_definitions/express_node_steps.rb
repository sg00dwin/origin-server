# 
# 
# Steps that can be used to check applications installed on a server (node)
#

$home_root = "/var/lib/stickshift"

# Convert a unix UID to a hex string suitable for use as a tc(1m) class value
def netclass uid
  "%04x" % uid
end


Then /^an account PAM limits file should( not)? exist$/ do |negate|
  limits_dir = '/etc/security/limits.d'
  pamfile = "#{limits_dir}/84-#{@account['accountname']}.conf"

  if negate
    assert_file_not_exists pamfile
  else
    assert_file_exists pamfile
  end
end

Then /^an account cgroup directory should( not)? exist$/ do |negate|
  cgroups_dir = '/cgroup/all/libra'
  cgdir = "#{cgroups_dir}/#{@account['accountname']}"

  if negate
    assert_directory_not_exists cgdir
  else
    assert_directory_exists cgdir
  end
end

Then /^selinux labels on the account home directory should be correct$/ do
  homedir = "#{$home_root}/#{@account['accountname']}"
  result = `restorecon -v -n #{homedir}`
  result.should be == "" 
end

Then /^disk quotas on the account home directory should be correct$/ do

  # EXAMPLE
  #
  # no such user
  # quota: user 00112233445566778899aabbccdde001 does not exist.
  #
  # no quotas on user
  # Disk quotas for user root (uid 0): none

  # Disk quotas for user 00112233445566778899aabbccdde000 (uid 501): 
  #    Filesystem  blocks   quota   limit   grace   files   quota   limit   grace
  #     /dev/xvde      24       0  131072               7       0   10000        
  #    

  result = `quota -u #{@account['accountname']}`
    
  result.should_not match /does not exist./
  result.should_not match /: none\s*\n?/
  result.should match /Filesystem  blocks   quota   limit   grace   files   quota   limit   grace/
end

Then /^a traffic control entry should( not)? exist$/ do |negate|
  acctname = @account['accountname']
  tc_format = 'tc -s class show dev eth0 classid 1:%s'
  tc_command = tc_format % (netclass @account['uid'])
  result = `#{tc_command}`
  if negate
    result.should be == ""
  else
    result.should_not be == ""
  end
end


# ===========================================================================
# Generic App Checks
# ===========================================================================
#
# ===========================================================================
# PHP App Checks
# ===========================================================================
#
# ===========================================================================
# WSGI App Checks
# ===========================================================================
#
# ===========================================================================
# Rack App Checks
# ===========================================================================
#
