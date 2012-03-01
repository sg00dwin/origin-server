class CloudUserObserver < ActiveModel::Observer
  observe CloudUser

  def before_cloud_user_create(user)
    raise StickShift::UserException.new("Invalid characters in login '#{user.login}' found", 107) if user.login =~ /["\$\^<>\|%\/;:,\\\*=~]/
  end

  def cloud_user_create_success(user)
    # add nurture and apptegic
    Express::Broker::Nurture.libra_contact(user.login, user.uuid, user.namespace, 'create')
    Express::Broker::Apptegic.libra_contact(user.login, user.uuid, user.namespace, 'create')
    # if any of the above fail, it will result in the user being deleted
  end

  def cloud_user_create_error(user)
    
  end

  def after_cloud_user_create(user)
  end

  def before_namespace_update(user)
  end

  def namespace_update_success(user)
    Express::Broker::Nurture.libra_contact(user.login, user.uuid, user.namespace, 'create')
    Express::Broker::Apptegic.libra_contact(user.login, user.uuid, user.namespace, 'create')
  end

  def namespace_update_error(user)
  end

  def after_namespace_update(user)
  end

end
