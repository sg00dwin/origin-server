class DomainObserver < ActiveModel::Observer
  observe Domain
  def domain_create_success(domain)
    send_data_to_analytics(domain)
  end

  def domain_update_success(domain)
    send_data_to_analytics(domain)
  end

  def send_data_to_analytics(domain)
    begin
      Rails.logger.debug "Sending updated domain info #{domain.namespace} to nurture"
      Online::Broker::Nurture.libra_contact(domain.owner.login, domain.owner._id, domain.namespace, 'update')
    rescue Exception => e
      Rail.logger.error "ERROR: sending analytic data #{e.message}"
    end
  end
end
