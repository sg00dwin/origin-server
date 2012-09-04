module Aria
  class MasterPlan < Plan
    self.element_name = 'plan'
    allow_anonymous

    def name
      aria_plan.plan_name
    end

    def description
      @description ||= short_description(aria_plan.plan_desc)
    end

    def max_gears
      capabilities.max_gears
    end

    def gear_sizes
      capabilities.gear_sizes
    end

    def features
      @features ||= Aria::MasterPlanFeature.from_description(aria_plan.plan_desc)
    end

    def feature(name)
      features.each { |feat|
        if feat.name == name
          return feat
        end
      }

      # Still here? Make a new bogus feature
      # for this name and add it to the list for future reference
      null_feature = Aria::MasterPlanFeature.new({ :name => name })
      @features << null_feature
      null_feature
    end

    cache_method :find_single,
                 lambda{ |*args| [MasterPlan.name, :find_single, args[0]] },
                 :before => lambda{ |p| p.as = nil; p.send(:aria_plan); p.send(:description); p.send(:features) }
    cache_method :find_every,
                 :before => lambda{ |plans| plans.each{ |p| p.as = nil; p.send(:aria_plan); p.send(:description); p.send(:features) } }

    protected
      def aria_plan
        @aria_plan ||= Aria.cached.get_client_plans_basic.find{ |plan| plan.plan_no == self.plan_no }
      end

      def short_description(plan_text)
        plan_text.each_line.map(&:chomp).split{ |s| s =~ /^\s*Features:/ }[0].join("\n").chomp
      end
  end
end
