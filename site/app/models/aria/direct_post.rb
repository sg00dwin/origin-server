module Aria
  class DirectPost

    class << self

      def get_or_create(plan, url)
        get_configured(plan) || create(plan, url)
      end

      def get_configured(plan=nil)
        if name_prefix.present?
          direct_post_name(plan)
        else
          nil
        end
      end

      def create(plan, url)
        name = direct_post_name(plan)
        Aria.set_reg_uss_config_params("direct_post_#{name}", {
          :redirecturl => url,
          :do_collect_or_validate => 0,
          :min_auth_threshold => 0,
          :do_cc_auth => 1,
          :change_status_on_cc_auth_failure => 0,
          :change_status_on_cc_auth_success => 1,
          :status_on_cc_auth_success => 1
        })
        name
      end

      def direct_post_name(plan)
        plan = plan.to_s if Symbol === plan
        prefix = name_prefix || `uname -n`.strip
        name = plan.nil? ? prefix : "#{prefix}_#{plan.is_a?(String) ? plan : plan.id}"
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
