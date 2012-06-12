require 'rubygems'
require 'pony'

module Express
  module AriaBilling
    class Notification

      def self.send_email(to, subject, body, from, password)
        Pony.mail(:to => to, 
                  :from => from, 
                  :subject => subject,
                  :html_body => body,
                  :via => :smtp,
                  :via_options => {
                    :address => 'smtp.gmail.com',
                    :port => '587',
                    :enable_starttls_auto => true,
                    :user_name => from,
                    :password => password,
                    :authentication => :plain
                  }
                 )
      end

      def self.report_event(event_id, response)
        subject = "Aria Event Notification: #{event_id}"
        from = "openshift.billing@gmail.com"
        password = "vostok08"
        to = "ariatesting@redhat.com"
    #    to = "OpenShift-Orders@redhat.com"

        if response.kind_of?(String)
          body = response
        else
          body = ""
          response.each do |k, v|
        body += "#{k} = #{v}\n"
          end if response
        end
        send_email(to, subject, body, from, password)
      end
    end
  end
end
