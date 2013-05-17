module CommunityHelper

  def faq_gear_sizes_url
    community_base_url 'faq/are-there-different-gear-sizes-and-how-much-do-they-cost'
  end

  def faq_add_on_storage_url
    community_base_url 'faq/what-is-add-on-storage'
  end

  def faq_ssl_for_domains_url
    community_base_url 'faq/how-do-i-get-ssl-for-my-domains'
  end

  def community_scaling_url
    community_base_url 'developers/scaling'
  end

  def community_security_policy_url
    community_base_url 'policy/security'
  end

  def community_zend_get_started_url
    community_base_url 'get-started/zend'
  end

  def enterprise_product_url
    community_base_url "enterprise-paas"
  end

  def red_hat_account_url
    'https://www.redhat.com/wapps/ugc'
  end

  def openshift_customer_portal_url
    'https://access.redhat.com/support/offerings/openshift/'
  end

  def open_bug_url
    'http://www.openshift.com/open-new-bug'
  end
end
