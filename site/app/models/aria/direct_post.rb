module Aria
  class DirectPost

    class << self

      def get_or_create(plan, url)
        get_configured(plan) || create(plan, url)
      end

      def get_configured(plan=nil)
        if name_prefix.present?
          plan.nil? ? name_prefix : "#{name_prefix}_#{plan.is_a?(String) ? plan : plan.id}"
        else
          nil
        end
      end

      def create(plan, url)
        prefix = name_prefix || `uname -n`.strip
        name = plan.nil? ? prefix : "#{prefix}_#{plan.is_a?(String) ? plan : plan.id}"
        Aria.set_reg_uss_config_params("direct_post_#{name}", {
          :redirecturl => url,
          :do_cc_auth => 1,
          :min_auth_threshold => 0,
          :change_status_on_cc_auth_success => 1,
          :status_on_cc_auth_success => 1,
          :change_status_on_cc_auth_failure => 1,
          :status_on_cc_auth_failure => -1,
        })
        name
      end

      def destroy(name=get_configured)
        raise "Direct post is not configured, cannot delete" if name.nil?
        Aria.clear_reg_uss_config_params("direct_post_#{name}")
        name
      end

      private
        def name_prefix
          Rails.configuration.aria_direct_post_name
        end
    end
  end
end
