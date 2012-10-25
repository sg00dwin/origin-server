require 'openshift-origin-common'

Broker::Application.configure do
  unless Rails.env.test?
    conf_file = File.join(OpenShift::Config::PLUGINS_DIR, File.basename(__FILE__, '.rb') + '.conf')
    if Rails.env.development?
      dev_conf_file = File.join(OpenShift::Config::PLUGINS_DIR, File.basename(__FILE__, '.rb') + '-dev.conf')
      if File.exist? dev_conf_file
        conf_file = dev_conf_file
      else
        Rails.logger.info "Development configuration for #{File.basename(__FILE__, '.rb')} not found. Using production configuration."
      end
    end
    conf = OpenShift::Config.new(conf_file)
    
    config.dns = {} unless config.respond_to? :dns
    config.dns[:zone]                 = conf.get("ZONE", "rhcloud.com")
    config.dns[:dynect_customer_name] = conf.get("DYNECT_CUSTOMER_NAME", "demo-redhat")
    config.dns[:dynect_user_name]     = conf.get("DYNECT_USER_NAME", "dev-rhcloud-user")
    config.dns[:dynect_password]      = conf.get("DYNECT_PASSWORD", "")
    config.dns[:dynect_url]           = conf.get("DYNECT_URL", "https://api2.dynect.net")
  end
end