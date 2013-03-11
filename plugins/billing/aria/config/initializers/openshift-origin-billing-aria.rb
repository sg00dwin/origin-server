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
    
    aria_billing_info = {
      :config => {
        :url => conf.get("BILLING_PROVIDER_URL", ""),
        :auth_key => conf.get("BILLING_PROVIDER_AUTH_KEY", ""),
        :client_no => conf.get("BILLING_PROVIDER_CLIENT_NO", "0").to_i,
        :enable_event_notification => conf.get_bool("BILLING_PROVIDER_EVENT_NOTIFICATION", "false"),
        :event_remote_ipaddr_begin => conf.get("BILLING_PROVIDER_EVENT_REMOTE_IPADDR_BEGIN", ""),
        :event_remote_ipaddr_end => conf.get("BILLING_PROVIDER_EVENT_REMOTE_IPADDR_END", ""),
        :event_orders_team_email => conf.get("BILLING_PROVIDER_EVENT_ORDERS_TEAM_EMAIL", ""),
        :event_peoples_team_email => conf.get("BILLING_PROVIDER_EVENT_PEOPLES_TEAM_EMAIL", "")
      },
      :usage_type => {
        :gear => {:small => 10014123,
                  :medium => 10014125,
                  :large => 10014127,
                  :xlarge => 10014151},
        :storage => {:gigabyte => 10037755},
        :cartridge => {:"jbosseap-6.0" => 10041319}
      },
      :default_plan => :freeshift,
      # Maintain the order of plans from lowest to the highest
      # Upgrade or Downgrade is decided based on this order.
      :plans => {
        :freeshift => {
          :plan_no => conf.get("FREESHIFT_PLAN_NO", 10044929).to_i,
          :name => "FreeShift",
          :capabilities => {
            'subaccounts' => false,
            'max_gears' => 3,
            'gear_sizes' => ["small"],
            'plan_upgrade_enabled' => true,
            'private_certificates' => false
          }
        },
        :megashift => {
          :plan_no => conf.get("MEGASHIFT_PLAN_NO", 10044931).to_i,
          :name => "MegaShift",
          :capabilities => {
            'subaccounts' => false,
            'max_gears' => 16,
            'gear_sizes' => ["small", "medium"],
            'max_storage_per_gear' => 30, # 30GB
            'plan_upgrade_enabled' => true,
            'private_certificates' => true
          },
          :usage_rates => {
            :gear => { 
                      :small => { 
                                 :usd => 0.05, #$/hr
                                 :duration => :hour
                                },
                      :medium => {
                                  :usd => 0.12, #$/hr
                                  :duration => :hour
                                 }
                     },
            :storage => {
                         :gigabyte => {
                                       :usd => 1.00, #$/month
                                       :duration => :month
                                      }
                        },
            :cartridge => {
                           :'jbosseap-6.0' => {
                                               :usd => 0.03, #$/hr
                                               :duration => :hour
                                              }
                          }
          }
        }
      }
    }
    config.billing = aria_billing_info
  end
end
