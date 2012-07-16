module PlanHelper
  def get_plan_id_from_plan_no(plan_no)
    access_info = Rails.application.config.billing[:aria]
    @plans = access_info[:plans]
    plan_id = nil
    @plans.each do |key, value|
      if value[:plan_no] == plan_no
      plan_id = key
      end
    end
    plan_id
  end
end