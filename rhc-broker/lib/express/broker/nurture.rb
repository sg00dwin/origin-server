module Express
  module Broker
    class Nurture
      def initialize()
      end

      #
      # Send application data (start, stop, etc)
      #
      def self.application(login, user_uuid, app_name, user_namespace, type, action, app_uuid)
        return unless Rails.configuration.analytics[:enabled] && Rails.configuration.analytics[:nurture][:enabled]
        Rails.logger.debug "DEBUG: Sending to Nurture:application: app_uuid='#{app_uuid}' action='#{action}'"
        # Why curl?  So I could & at the end.  We don't want this blocking requests
        # Please fix if you can :)  - mmcgrath
        system("curl -s -O /dev/null -X POST -u '#{Rails.configuration.analytics[:nurture][:username]}:#{Rails.configuration.analytics[:nurture][:password]}' '#{Rails.configuration.analytics[:nurture][:url]}applications' \
                --data-urlencode 'application[action]=#{action}' \
                --data-urlencode 'application[user_name]=#{login}' \
                --data-urlencode 'application[guid]=#{app_uuid}' \
                --data-urlencode 'application[uuid]=#{user_uuid}' \
                --data-urlencode 'application[name]=#{app_name}' \
                --data-urlencode 'application[version]=na' \
                --data-urlencode 'application[components]=#{type}' \
                --data-urlencode 'application[user_type]=express' &")
      end

      #
      # Send application data (git push, etc)
      #
      def self.application_update(action, app_uuid)
        return unless Rails.configuration.analytics[:enabled] && Rails.configuration.analytics[:nurture][:enabled]
        Rails.logger.debug "DEBUG: Sending to Nurture:application_update: app_uuid='#{app_uuid}' action='#{action}'"
        # Why curl?  So I could & at the end.  We don't want this blocking requests
        # Please fix if you can :)  - mmcgrath
        system("curl -s -O /dev/null -X POST -u '#{Rails.configuration.analytics[:nurture][:username]}:#{Rails.configuration.analytics[:nurture][:password]}' '#{Rails.configuration.analytics[:nurture][:url]}applications' \
                --data-urlencode 'application[action]=#{action}' \
                --data-urlencode 'application[guid]=#{app_uuid}' \
                --data-urlencode 'application[version]=na' \
                --data-urlencode 'application[user_type]=express' &")
      end

      #
      # Send account data (actual username)
      #
      def self.libra_contact(login, uuid, user_namespace, action)
        return unless Rails.configuration.analytics[:enabled] && Rails.configuration.analytics[:nurture][:enabled]
        Rails.logger.debug "User namespace #{user_namespace}"
        user_namespace = "" if not user_namespace
        Rails.logger.debug "DEBUG: Sending to Nurture:libra_contact: login='#{login}' namespace='#{user_namespace}' action='#{action}'"
        system("curl -s -O /dev/null -X POST -u '#{Rails.configuration.analytics[:nurture][:username]}:#{Rails.configuration.analytics[:nurture][:password]}' '#{Rails.configuration.analytics[:nurture][:url]}libra_contact' \
                --data-urlencode 'user_type=express' \
                --data-urlencode 'user[uuid]=#{uuid}' \
                --data-urlencode 'user[action]=#{action}' \
                --data-urlencode 'user[user_name]=#{login}' \
                --data-urlencode 'user[namespace]=#{user_namespace}' &")
      end
    end
  end
end
