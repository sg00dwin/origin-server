require 'cgi'
require 'uri'

#
# This class encapsulates calls made back to the IT systems via
# the streamline REST service.
class Streamline
  include ActiveModel::Naming
  include ActiveModel::Validations
  include ErrorCodes

  def self.login_url
    URI.parse(Rails.configuration.streamline + "/login.html")
  end

  def self.register_url
    URI.parse(Rails.configuration.streamline + "/registration.html")
  end

  def self.request_access_url
    URI.parse(Rails.configuration.streamline + "/requestAccess.html")
  end

  def self.roles_url
    URI.parse(Rails.configuration.streamline + "/cloudVerify.html")
  end

  def self.email_confirm_url(key, login)
    query = "key=#{key}&emailAddress=#{CGI::escape(login)}"
    URI.parse(Rails.configuration.streamline + "/confirm.html?#{query}")
  end

  def http_post(ticket, url, args={})
    begin
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data(args)

      # Include the ticket as a cookie if present
      req.add_field('Cookie', "rh_sso=#{ticket}") if ticket

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = http.start {|http| http.request(req)}

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        Rails.logger.debug("POST Response code = #{res.code}")

        # Set the rh_sso cookie as the ticket
        new_ticket = parse_ticket(res.get_fields('Set-Cookie'))

        # Parse and yield the body if a block is supplied
        if res.body and !res.body.empty?
          json = parse_body(res.body)
          yield new_ticket, json if block_given?
        end
      else
        log_error "Invalid HTTP response from streamline - #{res.code}"
        log_error "Response body:\n#{res.body}"
        raise StreamlineException
      end
    rescue Exception => e
      log_error "Exception occurred while calling streamline - #{e.message}"
      Rails.logger.error e, e.backtrace
      raise StreamlineException
    end
  end

  def log_error(msg)
    Rails.logger.error msg
    Libra.client_debug msg
  end

  #
  # Parse the rh_sso cookie out of the headers
  # and set it as the ticket
  #
  def parse_ticket(cookies)
    ticket = nil
    if cookies
      cookies.each do |cookie|
        if cookie.index("rh_sso")
          ticket = cookie.split('; ')[0].split("=")[1]
        end
      end
    end
    return ticket
  end

  #
  # Parse the response body, setting errors on the
  # user object as necessary.  Returns json structure
  #
  def parse_body(body)
    if body
      json = ActiveSupport::JSON::decode(body)
      parse_json_errors(json)
      return json
    end
  end

  def parse_json_errors(json)
    if json and json['errors']
      json['errors'].each do |error|
        msg = I18n.t error, :scope => :streamline, :default => I18n.t(:unknown)
        # Adding to :base is important for errors.full_messages to generate
        # appropriate error messages
        errors.add(:base, msg)
      end
    end
  end
end
