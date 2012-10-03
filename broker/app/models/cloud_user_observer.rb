class CloudUserObserver < ActiveModel::Observer
  observe CloudUser

  def before_cloud_user_create(user)
    raise StickShift::UserException.new("Invalid characters in login '#{user.login}' found", 107) if user.login =~ /["\$\^<>\|%\/;:,\\\*=~]/

    capabilities = {}
    if user.parent_user_login
      capabilities = user.get_capabilities
    elsif user.plan_id 
      raise StickShift::UserException.new("Specified plan_id does not exist", 150) if !Express::AriaBilling::Plan.instance.valid_plan(user.plan_id)
      plan_details = Rails.application.config.billing[:aria][:plans][user.plan_id.to_sym]
      user.capabilities = user.capabilities.merge(plan_details[:capabilities].dup)
      capabilities = user.capabilities
    else
      user.capabilities['gear_sizes'] = [Rails.application.config.ss[:default_gear_size]] unless user.capabilities.has_key?('gear_sizes')
      capabilities = user.capabilities
    end
    user.max_gears = capabilities['max_gears'] if capabilities.has_key?('max_gears')
    user.capabilities.delete('max_gears')
  end

  def cloud_user_create_success(user)
    # add nurture
    Express::Broker::Nurture.libra_contact(user.login, user.uuid, nil, 'create')
    # if any of the above fail, it will result in the user being deleted
  end

  def cloud_user_create_error(user)
    
  end

  def after_cloud_user_create(user)
  end

end
