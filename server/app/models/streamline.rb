require 'cgi'
require 'uri'

#
# This mixin encapsulates calls made back to the IT systems via
# the streamline REST service.
#
module Streamline
  include ErrorCodes
  attr_accessor :rhlogin, :ticket, :roles, :terms, :site_terms

  @@login_url = URI.parse(Rails.configuration.streamline + "/login.html")
  @@register_url = URI.parse(Rails.configuration.streamline + "/registration.html")
  @@request_access_url = URI.parse(Rails.configuration.streamline + "/requestAccess.html")
  @@roles_url = URI.parse(Rails.configuration.streamline + "/cloudVerify.html")
  @@email_confirm_url = URI.parse(Rails.configuration.streamline + "/confirm.html")
  @@user_info_url = URI.parse(Rails.configuration.streamline + "/userInfo.html")
  @@acknowledge_terms_url = URI.parse(Rails.configuration.streamline + "/protected/acknowledgeTerms.html")
  @@unacknowledged_terms_url = URI.parse(Rails.configuration.streamline + "/protected/findUnacknowledgedTerms.html?hostname=openshift.redhat.com&context=OPENSHIFT&locale=en")

  def initialize
    @roles = []
    @site_terms = []
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
    @site_terms = []
    http_post(@@unacknowledged_terms_url) do |json|
      terms = json['unacknowledgedTerms']
      terms.each do |term|
        if term['termUrl'] =~ /^http(s)?:\/\/openshift\.redhat\.com/
          @terms.push(term)
        else
          @site_terms.push(term)
        end
      end
    end
  end

  def refresh_roles(force=false)
    has_requested = force
    CloudAccess.ids.each do |id|
      if has_requested?(id)
        has_requested = true
        break
      end
    end unless has_requested
    if has_requested
      establish
    end
  end

  def accept_site_terms
    establish_terms
    accept_terms(@site_terms)
    @site_terms.clear if errors.empty?
  end

  def accept_subscription_terms(accepted_terms_json)
    Rails.logger.debug("Accepting subscription terms = #{accepted_terms_json}")
    establish_terms
    accepted_terms = parse_terms(accepted_terms_json)
    accept_terms(@terms, accepted_terms)
    @terms.clear if errors.empty?
  end

  def all_terms_accepted?(required_terms, accepted_terms)
    # Make sure that all the required terms are accepted
    required_terms.each do |term|
      if !accepted_terms.index(term['termId'])
        errors.add(:base, I18n.t(:terms_error, :scope => :streamline))
        Rails.logger.warn("Not all required terms accepted / \
                          req = #{required_terms.pretty_inspect} / \
                          accepted = #{accepted_terms.pretty_inspect}")
        break
      end
    end

    Rails.logger.debug("All terms accepted") if errors.empty?

    return errors.empty?
  end

  def accept_terms(required, accepted=nil)
    # Sanity check that all the terms made it back from the client
    if accepted
      return unless all_terms_accepted?(required, accepted)
    end

    Rails.logger.debug("Calling streamling to accept terms")
    http_post(build_terms_url(required), {}, false) do |json|
      # Log error on unknown result
      Rails.logger.error("Streamline accept terms failed") unless json['term']

      # Unless everything was accepted, put an error on the user object
      json['term'] ||= []

      # Convert the accepted ids to strings to comparison
      # normally they are integers
      required_conv = required.map{|v| v.to_s}
      unless (required_conv - json['term']).empty?
        Rails.logger.error("Streamline partial terms acceptance")
        errors.add(:base, I18n.t(:terms_error, :scope => :streamline))
      end
    end
  end

  #
  # Login the current user, setting the roles and ticket
  #
  def login
    # Clear out any existing ticket
    @ticket = nil

    # First do the authentication
    login_args = {'login' => @rhlogin,
                  'password' => @password,
                  'redirectUrl' => 'http://www.redhat.com'}

    # Establish the authentication ticket
    http_post(@@login_url, login_args)

    # Now retrieve the authorization roles
    http_post(@@roles_url) do |json|
      Rails.logger.debug("Current login = #{@rhlogin} / authenticated for #{json['username']}")
      if @rhlogin != json['username']
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
      http_post(@@user_info_url) do |json|
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
      else
        log_error "Invalid HTTP response from streamline - #{res.code}"
        log_error "Response body:\n#{res.body}"
        if raise_exception_on_error
          raise StreamlineException
        else
          errors.add(:base, I18n.t(:unknown))
        end
      end
    rescue Exception => e
      log_error "Exception occurred while calling streamline - #{e.message}"
      Rails.logger.error e, e.backtrace
      if raise_exception_on_error
        raise StreamlineException
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

  def parse_terms(terms_json)
    terms_json ? JSON.parse(terms_json) : []
  end

  def build_terms_query(terms)
    terms.collect {|id| "termIds=#{id}"}.join('&') if terms
  end

  def build_terms_url(terms)
    url = @@acknowledge_terms_url.clone
    url.query = build_terms_query(terms)
    url
  end
end
