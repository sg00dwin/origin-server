require "openshift-origin-common"

module OpenShift
  module AriaBillingServiceModule
    require 'aria_billing_engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  end
end

require "openshift/aria_plugin.rb"
require "openshift/aria_api_helper.rb"
require "openshift/aria_event.rb"
require "openshift/aria_notification.rb"
require "openshift/aria_exception.rb"
OpenShift::BillingService.provider=OpenShift::AriaPlugin
