require 'cgi'
require 'uri'

#
# This mixin encapsulates calls made back to the IT systems via
# the streamline REST service.
#
module Streamline
  include ErrorCodes
  attr_accessor :rhlogin, :ticket, :roles, :terms

  service_base_url = defined?(Rails) ? Rails.configuration.streamline + Rails.configuration.streamline_service_base_url : ""
  @@login_url = URI.parse(service_base_url + "/login.html")
  @@register_url = URI.parse(service_base_url + "/registration.html")
  @@request_access_url = URI.parse(service_base_url + "/requestAccess.html")
  @@roles_url = URI.parse(service_base_url + "/cloudVerify.html")
  @@email_confirm_url = URI.parse(service_base_url + "/confirm.html")
  @@user_info_url = URI.parse(service_base_url + "/userInfo.html")
  @@acknowledge_terms_url = URI.parse(service_base_url + "/protected/acknowledgeTerms.html")
  @@unacknowledged_terms_url = URI.parse(service_base_url + "/protected/findUnacknowledgedTerms.html?hostname=openshift.redhat.com&context=OPENSHIFT&locale=en")

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

  def establish_terms
    # If established, just return
    return if @terms

    # Otherwise, look them up
    @terms = []
    http_post(@@unacknowledged_terms_url) do |json|
      @terms = json['unacknowledgedTerms']
    end
  end

  def refresh_roles(force=false)
    has_requested = force
    CloudAccess::IDS.each do |id|
      if has_requested?(id)
        has_requested = true
        break
      end
    end unless has_requested
    if has_requested
      establish
    end
  end

  def accept_terms
    establish_terms
    Rails.logger.debug("Calling streamline to accept terms")
    http_post(build_terms_url(@terms), {}, false) do |json|
      # Log error on unknown result
      Rails.logger.error("Streamline accept terms failed") unless json['term']

      # Unless everything was accepted, put an error on the user object
      json['term'] ||= []

      # Convert the accepted ids to strings to comparison
      # normally they are integers
      terms_ids = @terms.map{|hash| hash['termId'].to_s}
      unless (terms_ids - json['term']).empty?
        Rails.logger.error("Streamline partial terms acceptance. Expected #{terms_ids} got #{json['term']}")
        errors.add(:base, I18n.t(:terms_error, :scope => :streamline))
      end
    end
    @terms.clear if errors.empty?
  end

  #
  # Login the current user, setting the roles and ticket
  #
  def login
    raise UserException.new(107), "Invalid characters in RHlogin '#{@rhlogin}' found", caller[0..5] if !Libra::Util.check_rhlogin(@rhlogin)

    # First do the authentication
    login_args = {'login' => @rhlogin,
                  'password' => @password,
                  'redirectUrl' => 'http://www.redhat.com'}

    result = nil

    begin
      # Establish the authentication ticket
      http_post(@@login_url, login_args)

      # Now retrieve the authorization roles
      http_post(@@roles_url) do |json|
        Rails.logger.debug("Current login = #{@rhlogin} / authenticated for #{json['username']}")
        @rhlogin = json['username']
        @roles = json['roles']
        unless roles.index('cloud_access_1')
          if roles.index('cloud_access_request_1')
            raise Libra::UserValidationException.new(146), "Found valid credentials but you haven't been granted access to Express yet", caller[0..5]
          else
            raise Libra::UserValidationException.new(147), "Found valid credentials but you haven't requested access to Express yet", caller[0..5]
          end
        end
      end

      result = @rhlogin
    rescue AccessDeniedException
    end

    return result
  end

  #
  # Register a new streamline user
  #
  def register(confirm_url)
    register_args = {'emailAddress' => @email_address,
                     'password' => @password,
                     'passwordConfirmation' => @password,
                     'secretKey' => Rails.configuration.streamline_secret,
                     'termsAccepted' => 'true',
                     'confirmationUrl' => confirm_url}

    http_post(@@register_url, register_args, false) do |json|
      unless json['emailAddress']
        if errors.length == 0
          errors.add(:base, I18n.t(:unknown))
        end
      end
    end
  end

  #
  # Request access to a cloud solution
  #
  def request_access(solution, amz_acct="")
    if has_requested?(solution)
      Rails.logger.warn("User already requested access")
      errors.add(:base, I18n.t(:already_requested_access, :scope => :streamline))
    elsif has_access?(solution)
      Rails.logger.warn("User already granted access")
      errors.add(:base, I18n.t(:already_granted_access, :scope => :streamline))
    else
      access_args = {'solution' => solution,
                     'amazonAccount' => amz_acct}
      # Make the request for access
      http_post(@@request_access_url, access_args, false) do |json|
        if json['solution']
          # success
        else
          if errors.length == 0
            errors.add(:base, I18n.t(:unknown))
          end
        end
      end
    end
  end

  #
  # Get the user's email address
  #
  def establish_email_address
    if !@email_address
      user_info_args = {'login' => @rhlogin,
                        'secretKey' => Rails.configuration.streamline_secret}
      http_post(@@user_info_url, user_info_args) do |json|
        @email_address = json['emailAddress']
      end
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

  def http_post(url, args={}, raise_exception_on_error=true)
    begin
      req = Net::HTTP::Post.new(url.path + (url.query ? ('?' + url.query) : ''))
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
      when Net::HTTPForbidden, Net::HTTPUnauthorized
        raise AccessDeniedException
      else
        log_error "Invalid HTTP response from streamline - #{res.code}"
        log_error "Response body:\n#{res.body}"
        if raise_exception_on_error
          raise StreamlineException
        else
          errors.add(:base, I18n.t(:unknown))
        end
      end
    rescue AccessDeniedException => e
      raise
    rescue Exception => e
      log_error "Exception occurred while calling streamline - #{e.message}"
      Rails.logger.error e, e.backtrace
      if raise_exception_on_error
        raise Libra::StreamlineException
      else
        errors.add(:base, I18n.t(:unknown))
      end
    end
  end

  def log_error(msg)
    Rails.logger.error msg
    if defined? Libra
      Libra.client_debug msg
    end
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

  def build_terms_query(terms)
    terms.collect {|hash| "termIds=#{hash['termId']}"}.join('&') if terms
  end

  def build_terms_url(terms)
    url = @@acknowledge_terms_url.clone
    url.query = build_terms_query(terms)
    url
  end
end
