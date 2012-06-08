module BillingHelper
require 'rubygems'
require 'tlsmail'
require 'parseconfig'

  def send_email(to, subject, body, from, password)
    content = <<EOF
From: #{from}
To: #{to}
subject: #{subject}
Date: #{Time.now.rfc2822}

#{body}
EOF
    print 'content', content

    Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
    Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com', from, password, :login) do |smtp|
      smtp.send_message(content, from, to)
    end
  end

  def report_event(event_id, response)
    subject = "Aria Event notification: #{event_id}"
    from = "openshift.billing@gmail.com"
    password = "vostok08"
    to = "ariatesting@redhat.com"
    body = ""
    response.each do |k, v|
      body += "#{k} = #{v}\n"
    end
    send_email(to, subject, body, from, password)
  end
end

def enable_broker(event_params)
  id_list = event_params[:event_id]
  id_list.each do |event_id|
    case event_id
      when "101"
        # account created.. get login and create a free account
        max_gears = Rails.configuration.ss[:default_max_gears]
        user = CloudUser.new(params[:userid])
      when "105"
    end
  end
end

