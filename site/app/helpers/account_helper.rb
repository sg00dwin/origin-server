module AccountHelper
  PlanUpgradeStepsCreate = [
    {
      :name => 'Plans',
      :link => 'account_plans_path',
    },
    {
      :name => 'Account and Billing',
    },
    {
      :name => 'Payment Information'
    },
    {
      :name => 'Review and Confirm',
      :link => 'new_account_plan_upgrade_path'
    }
  ]

  def plan_upgrade_steps(active, options={})
    wizard_steps(PlanUpgradeStepsCreate, active, options)
  end

  def tax_exempt_help_status
    community_base_url 'policy/tax-exemptions'
  end

  def line_item_details(li)
    if li.tax?
    elsif li.usage?
      "#{number_with_precision(li.units, :precision => 0)} @ #{number_to_currency(li.rate)} / #{li.units_label}"
    elsif li.recurring?
      if li.rate
        "#{number_to_currency(li.rate)} / month#{" (prorated)" if li.total_cost < 0}"
      elsif li.total_cost < 0
        "Service Credit"
      end
    end
  end
end
