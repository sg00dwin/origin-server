require "openshift-origin-common"

module OpenShift
  module AriaBillingServiceModule
    require 'aria_billing_engine' if defined?(Rails) && Rails::VERSION::MAJOR == 3
  end
end

require "openshift/aria_plugin.rb"
require "openshift/api_helper.rb"
require "openshift/event.rb"
require "openshift/notification.rb"
require "openshift/exception.rb"
OpenShift::BillingService.provider=OpenShift::AriaPlugin
