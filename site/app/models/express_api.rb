require 'uri'
require 'timeout'

module ExpressApi
  
  class BrokerUnauthorizedException < StandardError; end

  attr_accessor :rhlogin, :password, :ticket
  
  # API URLs
  base_url = Rails.configuration.express_api_url
  @@domain_url = URI.parse(base_url + '/broker/domain')
  @@userinfo_url = URI.parse(base_url + '/broker/userinfo')
  @@cartlist_url = URI.parse(base_url + '/broker/cartlist')
  @@app_url = URI.parse(base_url + '/broker/cartridge')
  @@ssh_key_url = URI.parse(base_url + '/broker/ssh_keys')

  def http_post(url, json_data={}, raise_exception = false)
    begin
      ExpressApi.http_post(url, json_data, @ticket, @password) do |json|
        yield json if block_given?
      end
    rescue Exception => e
      errors.add :base, e.message
      raise e if raise_exception
    end
  end

  # Post to an api url
  def self.http_post(url, json_data, ticket, password='')
    begin
      Rails.logger.debug "Posting to Express API"
      Rails.logger.debug "Url: #{url}"
      # define post request
      req = Net::HTTP::Post.new(url.path)
      form_data = {:json_data => ActiveSupport::JSON.encode(json_data)}
      form_data[:password] = password.blank? ? '' : password
      req.set_form_data(form_data)
      # Set ticket cookie
      req.add_field "Cookie", "rh_sso=#{ticket}" unless ticket.blank?
      Rails.logger.debug "cookies: #{req.to_hash.inspect}"
      # set up http connection
      # proxy = Net::HTTP::Proxy('file.rdu.redhat.com', 3128)
      # http = proxy.new(url.host, url.port)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      res = Timeout::timeout 30 do
        http.start {|http| http.request(req)}
      end

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
        raise BrokerUnauthorizedException
      else
        raise Exception
      end
    rescue Timeout::Error
      Rails.logger.error "Http call timed out"
      raise Exception, I18n.t('express_api.errors.timeout')
    rescue BrokerUnauthorizedException
      raise Exception, I18n.t('express_api.errors.unauthorized')
    rescue Exception => e
      Rails.logger.error "Exception occurred while calling Express API - #{e.message}"
      Rails.logger.error e, e.backtrace
      raise Exception, I18n.t(:unknown)
    end
  end
  
  def persisted?
    false
  end

end
