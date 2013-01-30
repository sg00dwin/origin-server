module BillingAware
  extend ActiveSupport::Concern

  included do
    include CapabilityAware
    helper_method :user_can_upgrade_plan?
  end

  protected
    def user_can_upgrade_plan?
      Rails.configuration.aria_enabled && current_user && !!user_capabilities.plan_upgrade_enabled
    rescue => e
      logger.error "Unable to check plan: #{e.message}\n  #{e.backtrace.join("\n  ")}"
      false
    end
end
