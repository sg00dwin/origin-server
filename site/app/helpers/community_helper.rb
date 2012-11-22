module CommunityHelper

  def faq_gear_sizes_url
    community_base_url 'faq/are-there-different-gear-sizes-and-how-much-do-they-cost'
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
end
