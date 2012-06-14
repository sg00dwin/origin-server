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

      def self.report_event(event_id, response, email_to)
        subject = "Aria Event Notification: #{event_id}"
        email_from = "openshift.billing@gmail.com"
        password = "vostok08"
        email_to = "ariatesting@redhat.com"

        if response.kind_of?(String)
          body = response
        else
          body = ""
          response.each do |k, v|
        body += "#{k} = #{v}\n"
          end if response
        end
        send_email(email_to, subject, body, email_from, password)
      end
    end
  end
end
