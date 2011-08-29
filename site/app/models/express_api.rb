require 'uri'

module ExpressApi
  
  attr_accessor :rhlogin, :password, :ticket
  
  # API URLs
  base_url = Rails.configuration.express_api_url
  @@domain_url = URI.parse(base_url + '/broker/domain')
  @@userinfo_url = URI.parse(base_url + '/broker/userinfo')
  @@cartlist_url = URI.parse(base_url + '/broker/cartlist')
  @@app_url = URI.parse(base_url + '/broker/cartridge')
  
  # Post to an api url
  def http_post(url, json_data={}, raise_exception = false)
    begin
      Rails.logger.debug "Posting to Express API"
      Rails.logger.debug "Url: #{url}"
      # define post request
      req = Net::HTTP::Post.new(url.path)
      form_data = {:json_data => ActiveSupport::JSON.encode(json_data)}
      form_data[:password] = @password.blank? ? '' : @password
      req.set_form_data(form_data)
      # Set ticket cookie
      req.add_field "Cookie", "rh_sso=#{@ticket}" unless @ticket.blank?
      Rails.logger.debug "cookies: #{req.to_hash.inspect}"
      # set up http connection
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = http.start {|http| http.request(req)}

      Rails.logger.debug "POST Response code = #{res.code}"
      
      # process response
      if res.content_type == 'application/json'
        # Parse and yield the body if a block is supplied
        if res.body and !res.body.empty?
          json = ActiveSupport::JSON.decode res.body
          Rails.logger.debug "in http_post decoded json: #{json.inspect}"
          yield json if block_given?
        end
      elsif res.is_a? Net::HTTPClientError
        errors.add(:base, I18n.t('express_api.errors.unauthorized'))
        raise Exception if raise_exception
      else
        errors.add(:base, I18n.t(:unknown))
        raise Exception if raise_exception
      end
    rescue Exception => e
      Rails.logger.error "Exception occurred while calling Express API - #{e.message}"
      Rails.logger.error e, e.backtrace
      # set error message if not already set
      errors.add(:base, I18n.t(:unknown)) if errors[:base].empty?
      if raise_exception
        raise
      end
    end
  end
  
  def persisted?
    false
  end

end
