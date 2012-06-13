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

      def enable_broker(event_params)
        id_list = event_params[:event_id]
        user = CloudUser.find(event_params[:userid])
        plan_name = event_params[:plan_name]
        if plan_name == "FreeShift"
          limits = @plans[:FreeShift]
        elsif plan_name == "MegaShift"
          limits = @plans[:MegaShift]
        else
          Rails.logger.error("Unknown plan #{plan_name} for user '#{user.name}'")
        end
        id_list.each do |event_id|
          case event_id
            when "101"
              if user.nil?
                user = CloudUser.new(params[:userid])
              end
              user.max_gears = limits[:max_gears]
              user.vip = limits[:vip]
              user.save
            when "107"
              if user.nil?
                Rails.logger.error("User not found : #{event_params[:userid]}")
                break
              end
              max_gears = limits[:max_gears]
              if max_gears < user.consumed_gears
                Rails.logger.error("Error in plan change for account '#{user.login}'. New plan #{plan_name} needs max_gears to be #{max_gears}, but current consumption is more (#{user.consumed_gears}).")
              end
              user.max_gears = max_gears
              user.vip = limits[:vip]
              user.save
          end
        end
      end
    end
  end
end
