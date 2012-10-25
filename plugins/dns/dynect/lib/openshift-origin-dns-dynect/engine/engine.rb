require 'openshift-origin-controller'
require 'rails'

module OpenShift
  class DynectDnsEngine < Rails::Engine
    paths.lib                  << "lib/openshift-origin-dynect-dns/lib"
    paths.config               << "lib/openshift-origin-dynect-dns/config"
    config.autoload_paths      += %W(#{config.root}/lib)
  end
end