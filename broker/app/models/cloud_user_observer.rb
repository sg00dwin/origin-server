class CloudUserObserver < ActiveModel::Observer
  observe CloudUser

  def before_cloud_user_create(user)
    raise StickShift::UserException.new("Invalid characters in login '#{user.login}' found", 107) if user.login =~ /["\$\^<>\|%\/;:,\\\*=~]/

    user.capabilities["gear_sizes"] = ["small"]
    if not user.parent_user_login.nil?
      user.capabilities["gear_sizes"] = [Rails.configuration.cloud9[:node_profile]] if user.parent_user_login == Rails.configuration.cloud9[:user_login]
    end
  end

  def cloud_user_create_success(user)
    # add nurture and apptegic
    Express::Broker::Nurture.libra_contact(user.login, user.uuid, nil, 'create')
    Express::Broker::Apptegic.libra_contact(user.login, user.uuid, nil, 'create')
    # if any of the above fail, it will result in the user being deleted
  end

  def cloud_user_create_error(user)
    
  end

  def after_cloud_user_create(user)
  end

end
