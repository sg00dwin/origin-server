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
    ''
  end

  # Check for user access
  def has_access?(product)
    false
    if controller.logged_in?
      case product
        when :express
          session_user.entitled?
      end
    end
  end

  # Check if user is logged in or not
  def logged_in?
    controller.logged_in?
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

  def newsletter_signup_url
    'http://makara.nurturehq.com/makara/newsletter_signup.html'
  end

  def irc_web_url
    'http://webchat.freenode.net/?randomnick=1&channels=openshift&uio=d4'
  end

  def link_to_irc
    link_to "IRC", irc_web_url
  end

  def openshift_twitter_hashtag_url
    'http://twitter.com/#!/search/%23OpenShift'
  end

  def openshift_twitter_url
    'http://www.twitter.com/#!/openshift'
  end

  def openshift_blog_url
    'https://www.redhat.com/openshift/blogs'
  end

  def open_bug_url
    'https://bugzilla.redhat.com/enter_bug.cgi?product=OpenShift%20Express'
  end

  def openshift_github_url
    'https://github.com/openshift'
  end

  def openshift_github_project_url(project)
    "https://github.com/openshift/#{project}"
  end

  def mailto_openshift_url
    'mailto:openshift@redhat.com'
  end

  def link_to_account_mailto
    link_to "openshift@redhat.com", mailto_openshift_url
  end

end
