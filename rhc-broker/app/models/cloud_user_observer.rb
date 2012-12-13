class CloudUserObserver < ActiveModel::Observer
  observe CloudUser

  def before_cloud_user_create(user)
    raise OpenShift::UserException.new("Invalid characters in login '#{user.login}' found", 107) if user.login =~ /["\$\^<>\|%\/;:,\\\*=~]/

    user_capabilities = user.get_capabilities
    if user.plan_id 
      raise OpenShift::UserException.new("Specified plan_id does not exist", 150) if !Express::AriaBilling::Plan.instance.valid_plan(user.plan_id)
      plan_details = Rails.application.config.billing[:aria][:plans][user.plan_id.to_sym]
      user.set_capabilities(user_capabilities.merge(plan_details[:capabilities].dup))
    end
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
