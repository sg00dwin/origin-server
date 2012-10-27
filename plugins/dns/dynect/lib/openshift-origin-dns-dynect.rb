require "openshift-origin-common"

module OpenShift
  module DynectDnsServiceModule
    require 'openshift-origin-dns-dynect/engine/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  end
end

require "openshift-origin-dns-dynect/lib/openshift/dynect_plugin.rb"
OpenShift::DnsService.provider=OpenShift::DynectPlugin