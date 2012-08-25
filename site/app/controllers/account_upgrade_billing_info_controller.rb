class AccountUpgradeBillingInfoController < BillingInfoController
  def next_path
    new_account_plan_upgrade_path
  end
end
