module ApplicationHelper

  # Checks for an outage notification
  def outage_notification
    notification = ''
    ['/etc/libra/outage_notification.txt', '/etc/libra/express_outage_notification.txt'].each do |file|
      if File.exists? file
        contents = nil
        f = File.open file
        begin
          contents = f.read
        ensure
          f.close
        end
        notification << content_tag(:pre,contents) unless contents.nil?
      end
    end
    
    if notification.length > 0
      content_tag(:div, "<h2>Outage Notification</h2>" + notification, {:id => 'outage_notification'}, false)
    else
      nil
    end
  end
  
  def get_cached(key, opts={})
    unless Rails.application.config.action_controller.perform_caching
      if block_given?
        return yield
      end
    end

    val = Rails.cache.read(key)
    unless val
      if block_given?
        val = yield
        if val
          Rails.cache.write(key, val, opts)
        end
      end
    end

    return val
  end

end
