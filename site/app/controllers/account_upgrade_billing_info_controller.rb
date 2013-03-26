class AccountUpgradeBillingInfoController < BillingInfoController
  def next_path
    account_plan_upgrade_path
  end
end
