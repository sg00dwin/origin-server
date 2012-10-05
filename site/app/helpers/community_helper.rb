module CommunityHelper

  def newsletter_signup_url
    community_base_url 'newsletter/signup'
  end

  def irc_web_url
    'http://webchat.freenode.net/?randomnick=1&channels=openshift&uio=d4'
  end

  def link_to_irc
    link_to "IRC", irc_web_url
  end

  def openshift_twitter_hashtag_url
    'http://twitter.com/#!/search/%23OpenShift'
  end

  def openshift_twitter_url
    'http://www.twitter.com/#!/openshift'
  end

  def open_bug_url
    'https://bugzilla.redhat.com/enter_bug.cgi?product=OpenShift'
  end

  def openshift_github_url
    'https://github.com/openshift'
  end

  def client_tools_url
    openshift_github_project_url 'rhc'
  end

  def origin_server_url
    openshift_github_project_url 'origin-server'
  end

  def origin_server_source_path_url(path)
    "#{openshift_github_project_url('origin-server')}/tree/master/#{path}"
  end

  def cartridges_source_url
    origin_server_source_path_url 'cartridges'
  end

  def origin_server_srpm_url
   "http://mirror.openshift.com/pub/origin-server/fedora-16/SRPMS/"
  end

  def openshift_github_project_url(project)
    "https://github.com/openshift/#{project}"
  end

  def red_hat_account_url
    'https://www.redhat.com/wapps/ugc'
  end

  def mailto_openshift_url
    'mailto:openshift@redhat.com'
  end

  def link_to_account_mailto
    link_to "openshift@redhat.com", mailto_openshift_url
  end

  def status_jsonp_url(id)
    status_js_path :id => id
  end

  def faq_gear_sizes_url
    '/community/faq/are-there-different-gear-sizes-and-how-much-do-they-cost'
  end

  def community_security_policy_url
    '/community/policy/security'
  end
end
