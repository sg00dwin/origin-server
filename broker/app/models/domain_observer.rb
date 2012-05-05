class DomainObserver < ActiveModel::Observer
  observe Domain
 
  def after_domain_create(domain)
    Rails.logger.debug "In after domain create"
    Rails.logger.debug "Sending updated domain info #{domain.namespace} to apptegic and nurture"
    Express::Broker::Nurture.libra_contact(domain.user.login, domain.user.uuid, domain.namespace, 'update')
    Express::Broker::Apptegic.libra_contact(domain.user.login, domain.user.uuid, domain.namespace, 'update')
    # if any of the above fail, it will result in the domain being deleted
  end
  
  def after_domain_update(domain)
    Rails.logger.debug "In after domain update"
    Rails.logger.debug "Sending updated domain info #{domain.namespace} to apptegic and nurture"
    Express::Broker::Nurture.libra_contact(domain.user.login, domain.user.uuid, domain.namespace, 'update')
    Express::Broker::Apptegic.libra_contact(domain.user.login, domain.user.uuid, domain.namespace, 'update')
    # if any of the above fail, it will result in the domain being deleted
  end
  
  def after_domain_destroy(domain)
    Rails.logger.debug "In after domain destroy"
    Rails.logger.debug "Sending updated domain info #{domain.namespace} to apptegic and nurture"
    Express::Broker::Nurture.libra_contact(domain.user.login, domain.user.uuid, domain.namespace, 'update')
    Express::Broker::Apptegic.libra_contact(domain.user.login, domain.user.uuid, domain.namespace, 'update')
    # if any of the above fail, it will result in the domain being deleted
  end

end
