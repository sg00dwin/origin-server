class DomainObserver < ActiveModel::Observer
  observe Domain
 
  def after_domain_create(domain)
    # add nurture and apptegic
    domains = []
    user.domains.each do |domain|
      domains.push(domain.namespace)
    end
    Express::Broker::Nurture.libra_contact(domain.user.login, domain.user.uuid, domains.join(", "), 'update')
    Express::Broker::Apptegic.libra_contact(domain.user.login, domain.user.uuid, domains.join(", "), 'update')
    # if any of the above fail, it will result in the domain being deleted
  end
  
  def after_domain_update(domain)
    # add nurture and apptegic
    domains = []
    user.domains.each do |domain|
      domains.push(domain.namespace)
    end
    Express::Broker::Nurture.libra_contact(domain.user.login, domain.user.uuid, domains.join(", "), 'update')
    Express::Broker::Apptegic.libra_contact(domain.user.login, domain.user.uuid, domains.join(", "), 'update')
    # if any of the above fail, it will result in the domain being deleted
  end
  
  def after_domain_destroy(domain)
    # add nurture and apptegic
    domains = []
    user.domains.each do |domain|
      domains.push(domain.namespace)
    end
    Express::Broker::Nurture.libra_contact(domain.user.login, domain.user.uuid, domains.join(", "), 'update')
    Express::Broker::Apptegic.libra_contact(domain.user.login, domain.user.uuid, domains.join(", "), 'update')
    # if any of the above fail, it will result in the domain being deleted
  end

end
