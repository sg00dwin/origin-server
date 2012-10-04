require "openshift-origin-common"
require "swingshift-streamline-plugin/swingshift/streamline_auth_service.rb"
OpenShift Origin::AuthService.provider=OpenShift Origin::StreamlineAuthService
