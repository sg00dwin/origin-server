
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
    -d 'application[action]=#{action}' \
    -d 'application[user_name]=#{rhlogin}' \
    -d 'application[guid]=#{uuid}' \
    -d 'application[name]=#{app_name}' \
    -d 'application[version]=na' \
    -d 'application[components]=#{type}' \
    -d 'application[user_type]=express' &`
        Libra.client_debug $?.exitstatus
    end
 
    #
    # Send account data (actual username)
    #
    def self.libra_contact(rhlogin, uuid, user_namespace)
        return unless (Libra.c[:nurture_enabled].to_s.downcase == 'true')
        Libra.client_debug "Sending to Nurture:libra_contact"
        `curl -s -O /dev/null -X POST -u '#{Libra.c[:nurture_username]}:#{Libra.c[:nurture_password]}' '#{Libra.c[:nurture_url]}/libra_contact' \
     -d "user_type=express" \
     -d "user[uuid]=#{uuid}" \
     -d "user[user_name]=#{rhlogin}" \
     -d "user[comments]=#{user_namespace}" &`
    end
  end
end
