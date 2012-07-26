module Express
  module AriaBilling
    class Plan
      attr_accessor :plans

      def initialize(access_info = nil)
        if access_info != nil
          # no-op
        elsif defined? Rails
          access_info = Rails.application.config.billing[:aria]
        else
          raise Exception.new("Aria Billing Plan is not inilialized")
        end
        @plans = access_info[:plans]
      end

      def self.instance
        Express::AriaBilling::Plan.new
      end

      def valid_plan(plan_id)
        @plans.keys.include?(plan_id)
      end
    end
  end
end
