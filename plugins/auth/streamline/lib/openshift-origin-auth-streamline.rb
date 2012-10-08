require "openshift-origin-common"
require "openshift-origin-auth-streamline/openshift/streamline_auth_service.rb"
OpenShift::AuthService.provider=OpenShift::StreamlineAuthService
