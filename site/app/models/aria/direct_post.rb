module Aria
  class DirectPost

    class << self

      def get_configured(plan_id)
        "#{name_prefix}_#{plan_id}" if name_prefix.present?
      end

      def new(plan_id, url)
        prefix = name_prefix || `uname -n`.strip
        name = "#{prefix}_#{plan_id}"
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

      def destroy(name)
        Aria.clear_reg_uss_config_params("direct_post_#{name}")
      end

      private
        def name_prefix
          Rails.configuration.aria_direct_post_name
        end
    end
  end
end
