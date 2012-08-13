module Aria
  class MasterPlan < Plan
    self.element_name = 'plan'
    allow_anonymous

    def description
      aria_plan.plan_desc
    end

    def max_gears
      capabilities.max_gears
    end

    def gear_sizes
      capabilities.gear_sizes
    end

    cache_find_method :single
    cache_find_method :every

    protected
      def aria_plan
        @aria_plan ||= Aria.cached.get_client_plans_basic.find{ |plan| plan.plan_no == self.plan_no }
      end

  end
end
