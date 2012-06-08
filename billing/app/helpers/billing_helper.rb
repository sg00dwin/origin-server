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
  user = CloudUser.find(event_params[:userid])
  plan_name = event_params[:plan_name]
  if plan_name == "DekaShift"
    limits = Rails.configuration.ss[:DekaShift]
  elsif plan_name == "MegaShift"
    limits = Rails.configuration.ss[:MegaShift]
  else
    Rails.logger.error("Unknown plan #{plan_name} for user '#{user.name}'")
  end
  id_list.each do |event_id|
    case event_id
      when "101"
        if user.nil?
          user = CloudUser.new(params[:userid])
        end
        user.max_gears = limits[:max_gears]
        user.vip = limits[:vip]
        user.save
      when "107"
        if user.nil?
          Rails.logger.error("User not found : #{event_params[:userid]}")
          break
        end
        max_gears = limits[:max_gears]
        if max_gears < user.consumed_gears
          Rails.logger.error("Error in plan change for account '#{user.login}'. New plan #{plan_name} needs max_gears to be #{max_gears}, but current consumption is more (#{user.consumed_gears}).")
        end
        user.max_gears = max_gears
        user.vip = limits[:vip]
        user.save
    end
  end
end

