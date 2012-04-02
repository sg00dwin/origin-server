module GearChanger
  class Nurture

    #
    # Send application data (start, stop, etc)
    #
    def self.application(login, user_uuid, app_name, user_namespace, type, action, app_uuid)
        return unless Rails.configuration.analytics[:nurture_enabled]
        Rails.logger.debug "DEBUG: Sending to Nurture:application: app_uuid='#{app_uuid}' action='#{action}'"
        # Why curl?  So I could & at the end.  We don't want this blocking requests
        # Please fix if you can :)  - mmcgrath
        `curl -s -O /dev/null -X POST -u '#{Rails.configuration.analytics[:nurture_username]}:#{Rails.configuration.analytics[:nurture_password]}' '#{Rails.configuration.analytics[:nurture_url]}applications' \
    --data-urlencode 'application[action]=#{action}' \
    --data-urlencode 'application[user_name]=#{login}' \
    --data-urlencode 'application[guid]=#{app_uuid}' \
    --data-urlencode 'application[uuid]=#{user_uuid}' \
    --data-urlencode 'application[name]=#{app_name}' \
    --data-urlencode 'application[version]=na' \
    --data-urlencode 'application[components]=#{type}' \
    --data-urlencode 'application[user_type]=express' &`
        Rails.logger.debug $?.exitstatus
    end
  end
end
