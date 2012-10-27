require "openshift-origin-common"

module OpenShift
  module StreamlineAuthServiceModule
    require 'openshift-origin-auth-streamline/engine/engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  end
end

require "openshift-origin-auth-streamline/lib/openshift/streamline_auth_service.rb"
OpenShift::AuthService.provider=OpenShift::StreamlineAuthService