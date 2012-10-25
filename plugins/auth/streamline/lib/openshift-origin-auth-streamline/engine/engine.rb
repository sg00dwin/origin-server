require 'openshift-origin-controller'
require 'rails'

module OpenShift
  class StreamlineAuthServiceEngine < Rails::Engine
    paths.app.controllers      << "lib/openshift-origin-auth-streamline/app/controllers"
    paths.lib                  << "lib/openshift-origin-auth-streamline/lib"
    paths.config               << "lib/openshift-origin-auth-streamline/config"
    config.autoload_paths      += %W(#{config.root}/lib)
  end
end
