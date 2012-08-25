module AccountHelper
  PlanUpgradeStepsCreate = [
    {
      :name => 'OpenShift plans',
      :link => 'account_plans_path',
    },
    {
      :name => 'Provide contact info',
    },
    {
      :name => 'Enter payment method'
    },
    {
      :name => 'Confirm upgrade',
      :link => 'new_account_plan_upgrade_path'
    }
  ]

  def plan_upgrade_steps(active, options={})
    wizard_steps(PlanUpgradeStepsCreate, active, options)
  end
end
