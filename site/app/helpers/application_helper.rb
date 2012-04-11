require 'net/geoip'

module ApplicationHelper
  # Checks for an outage notification
  def outage_notification
    notification = ''
    ['/etc/stickshift/outage_notification.txt', '/etc/stickshift/express_outage_notification.txt'].each do |file|
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
    ['express'].each do |product|
      unless controller.index(product).nil? and action.index(product).nil?
        return product
      end
    end
    return ''
  end
  
  # Check if user is logged in or not
  def logged_in?
    return controller.logged_in?
  end
  
  # Check for user access
  def has_access?(product)
    false
    if controller.logged_in?
      case product
        when :express
          session[:user].has_access?(CloudAccess::EXPRESS)
      end
    end
  end
  
  # Detect previous login
  def previously_logged_in?
    controller.previously_logged_in?
  end
  
  # localized video URL
  def local_video_url(video)
    vid = local_video(video)

    if :youtube == vid[:provider]
      "http://www.youtube.com/watch?v=#{vid[:id]}"
    elsif :tudou == vid[:provider]
      "http://www.tudou.com/programs/view/#{vid[:id]}/"
    end
  end

  def local_video(video)
    chinese_country_codes = ['CN', 'DC', 'TW']

    # determine country code of visitor
    geo = Net::GeoIP.new()
    country_code = geo.country_code_by_addr(request.remote_ip)

    if chinese_country_codes.include?(country_code)
      vid_provider = :tudou
      vid_locale = :zh_CN
    else
      vid_provider = :youtube
      vid_locale = :en
    end

    vid_id = I18n.t video, :locale => vid_locale, :scope => 'openshift.videos', :default => ''

    if vid_id.empty?
      raise StandardError, "Undefined video with key: #{video}"
    else
      { :provider => vid_provider, :id => vid_id }
    end
  end

  def upgrade_in_rails_31
    raise "Code needs upgrade for rails 3.1+" if Rails.version[0..3] != '3.0.'
  end

  def wrap_long_string(text, max_width = 150)
    (text.length < max_width) ? text : text.scan(/.{1,#{max_width}}/).join("<wbr>")
  end
end
