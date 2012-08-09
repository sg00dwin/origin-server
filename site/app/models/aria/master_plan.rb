module Aria
  class MasterPlan < Plan
    self.element_name = 'plan'

    def description
      aria_plan.plan_desc
    end

    def max_gears
      capabilities.max_gears
    end

    def gear_sizes
      capabilities.gear_sizes
    end

    protected
      def aria_plan
        @aria_plan ||= Aria.get_client_plans_basic.find{ |plan| plan.plan_no == self.plan_no }
      end
  end
end
