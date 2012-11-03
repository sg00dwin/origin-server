require "openshift-origin-common"

module OpenShift
  module StreamlineAuthServiceModule
    require 'engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  end
end

require "openshift/streamline_auth_service.rb"
OpenShift::AuthService.provider=OpenShift::StreamlineAuthService
