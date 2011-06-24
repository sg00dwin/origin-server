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
  
  # Which product is the current page referring to?
  def get_product(controller, action)
    ['express', 'flex', 'power'].each do |product|
      unless controller.index(product).nil? and action.index(product).nil?
        return product
      end
    end
    return ''
  end
  
end
