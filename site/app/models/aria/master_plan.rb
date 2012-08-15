module Aria
  class MasterPlan < Plan
    self.element_name = 'plan'
    allow_anonymous

    def name
      aria_plan.plan_name
    end

    def description
      aria_plan.plan_desc
    end

    def max_gears
      capabilities.max_gears
    end

    def gear_sizes
      capabilities.gear_sizes
    end

    cache_method :find_single, lambda{ |*args| [MasterPlan.name, :find_single, args[0]] }, :before => remove_authorization_from_model
    cache_find_method :every

    protected
      def aria_plan
        @aria_plan ||= Aria.cached.get_client_plans_basic.find{ |plan| plan.plan_no == self.plan_no }
      end

  end
end
