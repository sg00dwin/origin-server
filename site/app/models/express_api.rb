require 'uri'

module 'ExpressAPI'

  attr_accessor :rhlogin, :password
  
  validates_presence_of :rhlogin
  validates :password, :presence => true,
                       :length => {:minimum => 6} 

  # API URLs
  base_url = Rails.configuration.express_api_url
  @@domain_url = URI.parse(base_url + '/broker/domain')
  
  # Post to an api url
  def http_post(url, json_data={})
    begin
      req = Net::HTTP::Post.new(url.path + (url.query ? ('?' + url.query) : ''))
      req.set_form_data({'json_data' => json_data, 'password' => @password})

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = http.start {|http| http.request(req)}

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        Rails.logger.debug("POST Response code = #{res.code}")

        # Parse and yield the body if a block is supplied
        if res.body and !res.body.empty?
          json = parse_body(res.body)
          yield json if block_given?
        end
      when Net::HTTPForbidden, Net::HTTPUnauthorized
        errors.add(:base, I18n.t('express_api.errors.unauthorized'))
      end
    rescue Exception => e
      log_error "Exception occurred while calling Express API - #{e.message}"
      Rails.logger.error e, e.backtrace
      errors.add(:base, I18n.t(:unknown))
    end
  end
  
end
