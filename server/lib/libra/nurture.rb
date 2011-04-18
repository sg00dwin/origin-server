
module Libra
  class Nurture
    def initialize()
    end

    #
    # Send application data (start, stop, etc)
    #
    def self.application(rhlogin, uuid, app_name, user_namespace, type, action)
        return unless (Libra.c[:nurture_enabled].to_s.downcase == 'true')
        Libra.client_debug "Sending to Nurture:application"
        # Why curl?  So I could & at the end.  We don't want this blocking requests
        # Please fix if you can :)  - mmcgrath
        `curl -s -O /dev/null -X POST -u '#{Libra.c[:nurture_username]}:#{Libra.c[:nurture_password]}' '#{Libra.c[:nurture_url]}applications' \
    --data-urlencode 'application[action]=#{action}' \
    --data-urlencode 'application[user_name]=#{rhlogin}' \
    --data-urlencode 'application[guid]=#{app_name}-#{user_namespace}' \
    --data-urlencode 'application[uuid]=#{uuid}' \
    --data-urlencode 'application[name]=#{app_name}' \
    --data-urlencode 'application[version]=na' \
    --data-urlencode 'application[components]=#{type}' \
    --data-urlencode 'application[user_type]=express' &`
        Libra.client_debug $?.exitstatus
    end
 
    #
    # Send account data (actual username)
    #
    def self.libra_contact(rhlogin, uuid, user_namespace)
        return unless (Libra.c[:nurture_enabled].to_s.downcase == 'true')
        Libra.client_debug "Sending to Nurture:libra_contact"
        `curl -s -O /dev/null -X POST -u '#{Libra.c[:nurture_username]}:#{Libra.c[:nurture_password]}' '#{Libra.c[:nurture_url]}/libra_contact' \
     --data-urlencode "user_type=express" \
     --data-urlencode "user[uuid]=#{uuid}" \
     --data-urlencode "user[user_name]=#{rhlogin}" \
     --data-urlencode "user[comments]=#{user_namespace}" &`
    end
  end
end
