module ControlPanelHelper
  def app_url_for( userinfo, app_name )
    "#{app_name}-#{userinfo.namespace}.#{userinfo.rhc_domain}"
  end
  
  def app_link_to( userinfo, app_name )
    app_url = 'http://' 
    app_url << app_url_for( userinfo, app_name )
    link_to app_url, app_url
  end
  
  def git_url_for( userinfo, app_name )
    app_uuid = userinfo.app_info[ app_name ]['uuid']
    app_url = app_url_for userinfo, app_name
    "ssh://#{app_uuid}@#{app_url}/~/git/#{app_name}.git/"
  end
  
end
