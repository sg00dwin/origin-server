require "openshift-origin-common"
require "openshift-origin-dns-dynect/openshift/dynect_plugin.rb"
OpenShift::DnsService.provider=OpenShift::DynectPlugin
