require 'uri'

module ExpressApi
  
  attr_accessor :rhlogin, :password
  
  # API URLs
  base_url = Rails.configuration.express_api_server
  @@domain_url = URI.parse(base_url + '/broker/domain')
  
  # Post to an api url
  def http_post(url, json_data={})
    begin
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data({'json_data' => json_data, 'password' => @password})

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = http.start {|http| http.request(req)}

      if res.is_a? Net::HTTPSuccess
        Rails.logger.debug("POST Response code = #{res.code}")

        # Parse and yield the body if a block is supplied
        if res.body and !res.body.empty?
          json = ActiveSupport::JSON.decode(res.body)
          yield json if block_given?
        end
      elsif res.is_a? Net::HTTPClientError
        errors.add(:base, I18n.t('express_api.errors.unauthorized'))
      else
        errors.add(:base, I18n.t(:unknown))
      end
    rescue Exception => e
      Rails.logger.error "Exception occurred while calling Express API - #{e.message}"
      Rails.logger.error e, e.backtrace
      errors.add(:base, I18n.t(:unknown))
    end
  end
end
