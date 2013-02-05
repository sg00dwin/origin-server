Console::Engine.require_relative(__FILE__)

class User
  def plan
    @plan ||= Aria::MasterPlan.cached.find(plan_id) if plan_id
  end
  def plan=(plan)
    @plan_id = plan.is_a?(String) ? plan : plan.id
  end

  def plan_upgrade_enabled
    !!capabilities[:plan_upgrade_enabled]
  end
end

