require 'openshift-origin-common'

Broker::Application.configure do

  conf_file = File.join(OpenShift::Config::PLUGINS_DIR, File.basename(__FILE__, '.rb') + '.conf')
  unless Rails.env.production?
    dev_conf_file = File.join(OpenShift::Config::PLUGINS_DIR, File.basename(__FILE__, '.rb') + '-dev.conf')
    if File.exist? dev_conf_file
      conf_file = dev_conf_file
    else
      Rails.logger.info "Development configuration for #{File.basename(__FILE__, '.rb')} not found. Using production configuration."
    end
  end
  conf = OpenShift::Config.new(conf_file)

  config.auth[:integrated]      = conf.get_bool("INTEGRATED_AUTH", "false")
  config.auth[:token_login_key] = conf.get("TOKEN_LOGIN_KEY", "rhlogin").to_sym
  config.auth[:auth_service]    = {
    :host     => conf.get("AUTH_SERVICE_HOST", "https://streamline-proxy1.ops.rhcloud.com"),
    :base_url => conf.get("AUTH_SERVICE_BASE_URL", "/wapps/streamline")
  }
end
