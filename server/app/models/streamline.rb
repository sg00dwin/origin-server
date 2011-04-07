require 'cgi'
require 'uri'

#
# This mixin encapsulates calls made back to the IT systems via
# the streamline REST service.
#
module Streamline
  include ErrorCodes
  attr_accessor :rhlogin, :ticket, :roles

  @@login_url = Rails.configuration.streamline + "/login.html"
  @@register_url = Rails.configuration.streamline + "/registration.html"
  @@request_access_url = Rails.configuration.streamline + "/requestAccess.html"
  @@roles_url = Rails.configuration.streamline + "/cloudVerify.html"
  @@email_confirm_url = Rails.configuration.streamline + "/confirm.html"

  def initialize
    @roles = []
  end

  def email_confirm_url(key, login)
    query = "key=#{key}&emailAddress=#{CGI::escape(login)}"
    URI.parse("#{@@email_confirm_url}?#{query}")
  end

  #
  # Establish the user state based on the current ticket
  #
  # Returns the login
  #
  def establish
    http_post(@@roles_url) do |json|
      @roles = json['roles']
      @rhlogin = json['username']
    end
  end

  #
  # Login the current user, setting the roles and ticket
  #
  def login(rhlogin, password)
    # Clear out any existing ticket
    @ticket = nil

    # First do the authentication
    login_args = {'login' => rhlogin,
                  'password' => password,
                  'redirectUrl' => 'http://www.redhat.com'}

    # Establish the authentication ticket
    http_post(@@login_url, login_args)

    # Now retrieve the authorization roles
    http_post(@@roles_url) do |json|
      Rails.logger.debug("Current login = #{rhlogin} / authenticated for #{json['username']}")
      if rhlogin != json['username']
        # We had a ticket collision - DO NOT proceed
        Rails.logger.error("Ticket collision - #{@ticket}")
        raise StreamlineException
      end

      @roles = json['roles']
    end
  end

  #
  # Register a new streamline user
  #
  def register(emailAddress, password, confirm_url)
    register_args = {'emailAddress' => emailAddress,
                     'password' => password,
                     'passwordConfirmation' => password,
                     'secretKey' => Rails.configuration.streamline_secret,
                     'termsAccepted' => 'true',
                     'confirmationUrl' => confirm_url}

    http_post(@@register_url, register_args) do |json|
      unless json['emailAddress']
        errors.add(:base, I18n.t(:unknown))
      end
    end
  end

  #
  # Request access to a cloud solution
  #
  def request_access(solution, amz_acct="")
    if has_requested?(solution) or has_access?(solution)
      Rails.logger.warn("User #{@emailAddress} already requested access - ignoring")
    else
      access_args = {'solution' => solution,
                     'amazon_account' => amz_acct}

      # Make the request for access
      http_post(@@request_access_url, access_args)
    end
  end

  #
  # Whether the user is authorized for a given cloud solution
  #
  def has_access?(solution)
    @roles.index(CloudAccess.auth_role(solution)) != nil
  end

  #
  # Whether the user has already requested access for a given cloud solution
  #
  def has_requested?(solution)
    @roles.index(CloudAccess.req_role(solution)) != nil
  end

  def http_post(url, args={})
    begin
      req = Net::HTTP::Post.new(url.path)
      req.set_form_data(args)

      # Include the ticket as a cookie if present
      req.add_field('Cookie', "rh_sso=#{@ticket}") if @ticket

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      res = http.start {|http| http.request(req)}

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        Rails.logger.debug("POST Response code = #{res.code}")

        # Set the rh_sso cookie as the ticket
        parse_ticket(res.get_fields('Set-Cookie'))

        # Parse and yield the body if a block is supplied
        if res.body and !res.body.empty?
          json = parse_body(res.body)
          yield json if block_given?
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
    if cookies
      cookies.each do |cookie|
        if cookie.index("rh_sso")
          @ticket = cookie.split('; ')[0].split("=")[1]
          break
        end
      end
    end
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
