class ApplicationController < ActionController::Base
  before_filter :store_user_agent
  
  @@outage_notification_file = '/etc/stickshift/express_outage_notification.txt'  
  
  def store_user_agent
    user_agent = request.headers['User-Agent']
    Rails.logger.debug "User-Agent = '#{user_agent}'"
    Thread.current[:user_agent] = user_agent
  end
  
  def notifications
    details = nil
    if File.exists?(@@outage_notification_file)
      file = File.open(@@outage_notification_file, "r")
      begin
        details = file.read
      ensure
        file.close
      end
    end
    
    details
  end
end
