
module Libra
  class Apptegic
    def initialize()
    end

    #
    # Send application data (start, stop, etc)
    #
    def self.application(rhlogin, user_uuid, app_name, user_namespace, type, action, app_uuid)
        return unless (Libra.c[:apptegic_enabled].to_s.downcase == 'true')
        Libra.logger_debug "DEBUG: Sending to Apptegic:application: app_uuid='#{app_uuid}' action='#{action}'"
        # Why curl?  So I could & at the end.  We don't want this blocking requests
        # Please fix if you can :)  - mmcgrath
        `curl -s -O /dev/null '#{Libra.c[:apptegic_url]}' \
    --data-urlencode '_ak=#{Libra.c[:apptegic_key]}' \
    --data-urlencode '_at=#{Libra.c[:apptegic_secret]}' \
    --data-urlencode '_ds=#{Libra.c[:apptegic_dataset]}' \
    --data-urlencode 'accountId=#{rhlogin}' \
    --data-urlencode 'accountType=regular' \
    --data-urlencode 'userId=#{rhlogin}' \
    --data-urlencode 'user_uuid=#{user_uuid}' \
    --data-urlencode 'app_uuid=#{app_uuid}' \
    --data-urlencode 'app_name=#{app_name}' \
    --data-urlencode 'app_type=#{type}' \
    --data-urlencode 'action=#{action}' \
    --data-urlencode 'platform=express' &`
        Libra.logger_debug $?.exitstatus
    end
    
    #
    # Send application data (git push, etc)
    #
    def self.application_update(action, app_uuid)
        return unless (Libra.c[:apptegic_enabled].to_s.downcase == 'true')
        Libra.logger_debug "DEBUG: Sending to Apptegic:application_update: app_uuid='#{app_uuid}' action='#{action}'"
        # Why curl?  So I could & at the end.  We don't want this blocking requests
        # Please fix if you can :)  - mmcgrath
        `curl -s -O /dev/null '#{Libra.c[:apptegic_url]}' \
    --data-urlencode '_ak=#{Libra.c[:apptegic_key]}' \
    --data-urlencode '_at=#{Libra.c[:apptegic_secret]}' \
    --data-urlencode '_ds=#{Libra.c[:apptegic_dataset]}' \
    --data-urlencode 'action=#{action}' \
    --data-urlencode 'app_uuid=#{app_uuid}' \
    --data-urlencode 'platform=express' &`
        Libra.logger_debug $?.exitstatus
    end
 
    #
    # Send account data (actual username)
    #
    def self.libra_contact(rhlogin, uuid, user_namespace, action)
        return unless (Libra.c[:apptegic_enabled].to_s.downcase == 'true')
        Libra.logger_debug "DEBUG: Sending to Apptegic:libra_contact: userId='#{rhlogin}' namespace='#{user_namespace}' action='#{action}'"
        `curl -s -O /dev/null '#{Libra.c[:apptegic_url]}' \
    --data-urlencode '_ak=#{Libra.c[:apptegic_key]}' \
    --data-urlencode '_at=#{Libra.c[:apptegic_secret]}' \
    --data-urlencode '_ds=#{Libra.c[:apptegic_dataset]}' \
    --data-urlencode 'accountId=#{rhlogin}' \
    --data-urlencode 'accountType=regular' \
    --data-urlencode 'userId=#{rhlogin}' \
    --data-urlencode 'namespace=#{user_namespace}' \
    --data-urlencode 'action=#{action}' \
    --data-urlencode 'user_uuid=#{uuid}' \
    --data-urlencode 'platform=express' &`
        Libra.logger_debug $?.exitstatus
    end
  end
end
