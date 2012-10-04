require "openshift-origin-common"
require "uplift-dynect-plugin/uplift/dynect_plugin.rb"
OpenShift::DnsService.provider=OpenShift::DynectPlugin
