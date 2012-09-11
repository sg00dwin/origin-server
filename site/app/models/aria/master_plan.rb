module Aria
  class MasterPlan < Plan
    self.element_name = 'plan'
    allow_anonymous

    def name
      aria_plan.plan_name
    end

    def description
      @description ||= aria_description(aria_plan.plan_desc)
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

    # Find a feature of the given name or create a new 'null' feature to represent it
    def feature(name)
      features.each { |feat|
        if feat.name == name
          return feat
        end
      }

      null_feature = Aria::MasterPlanFeature.new({ :name => name })
      @features << null_feature
      null_feature
    end

    # Compare plans first by their 'Price' feature, and then by their gear
    # size offerings.
    def <=>(other)
      price_comparison = feature('Price').<=>(other.feature('Price'))
      case
      when price_comparison == 0
        gear_sizes.length.<=>(other.gear_sizes.length)
      else
        price_comparison
      end
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

      def aria_description(plan_text)
        plan_text.each_line.map(&:chomp).split{ |s| s =~ /^\s*Features:/ }[0].join("\n").chomp.html_safe
      end
  end
end
