if RUBY_VERSION.to_f == 1.8
require 'net/geoip' rescue Rails.logger.error "Net::GeoIP not available, unable to serve country specific videos."
end

module VideoHelper
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
    vid_provider = :youtube
    vid_locale = :en

    if defined? Net::GeoIP
      chinese_country_codes = ['CN', 'DC', 'TW']

      # determine country code of visitor
      geo = Net::GeoIP.new()
      country_code = geo.country_code_by_addr(request.remote_ip)

      if chinese_country_codes.include?(country_code)
        vid_provider = :tudou
        vid_locale = :zh_CN
      end
    end

    vid_id = I18n.t video, :locale => vid_locale, :scope => 'openshift.videos', :default => ''

    if vid_id.empty?
      raise StandardError, "Undefined video with key: #{video}"
    else
      { :provider => vid_provider, :id => vid_id }
    end
  end
end

