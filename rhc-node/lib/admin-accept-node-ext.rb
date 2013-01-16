def selinux_policy_name
  'openshift-hosted'
end

def ext_packages
  [ 'rhc-common', 'rhc-node', 'rhc-selinux' ]
end
