class CloudUserObserver < ActiveModel::Observer
  include UtilHelper
  observe CloudUser

  def before_cloud_user_create(user)
    raise OpenShift::UserException.new("Invalid characters in login '#{user.login}' found", 107) if user.login =~ /["\$\^<>\|%\/;:,\\\*=~]/

    #plan_id = user.plan_id || Rails.configuration.billing[:aria][:default_plan]
    #user.assign_plan(plan_id) if plan_id
    #if plan_id and !user.plan_id and not user.capabilities_changed?
    #  user.assign_plan(plan_id)
    #end
  end

  def cloud_user_create_success(user)
    # add nurture
    Express::Broker::Nurture.libra_contact(user.login, user._id, nil, 'create')
    # if any of the above fail, it will result in the user being deleted
  end

  def cloud_user_create_error(user)
  end

  def after_cloud_user_create(user)
  end

end
