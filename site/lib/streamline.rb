require 'cgi'
require 'uri'
require 'streamline_mock'
require 'error_codes'
require 'exception'

#
# This mixin encapsulates calls made back to the IT systems via
# the streamline REST service.
#
module Streamline
  include ErrorCodes
  attr_accessor :rhlogin, :ticket, :roles, :terms

  # Raised when the reset token has already been used
  class TokenExpired < Streamline::StreamlineException
  end

  class Cookie
    def initialize(*arguments)
      @name, @value, @options = arguments
    end
    def to_s
      "#{@name}=#{@value}"
    end
  end

  service_base_url = defined?(Rails) ? Rails.configuration.streamline[:host] + Rails.configuration.streamline[:base_url] : ""

  @@login_url = URI.parse(service_base_url + "/login.html")
  @@register_url = URI.parse(service_base_url + "/registration.html")

  @@request_access_url = URI.parse(service_base_url + "/requestAccess.html")
  @@roles_url = URI.parse(service_base_url + "/cloudVerify.html")
  @@email_confirm_url = URI.parse(service_base_url + "/confirm.html")
  @@user_info_url = URI.parse(service_base_url + "/userInfo.html")

  @@acknowledge_terms_url = URI.parse(service_base_url + "/protected/acknowledgeTerms.html")
  @@unacknowledged_terms_url = URI.parse(service_base_url + "/protected/findUnacknowledgedTerms.html?hostname=openshift.redhat.com&context=OPENSHIFT&locale=en")

  @@change_password_url = URI.parse(service_base_url + '/protected/changePassword.html')
  @@request_password_reset_url = URI.parse(service_base_url + '/resetPassword.html')
  @@reset_password_url = URI.parse(service_base_url + '/resetPasswordConfirmed.html')

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
  # <b>DEPRECATED:</b> Use establish_roles
  def establish
    http_post(@@roles_url) do |json|
      @initialized_roles = true
      @roles = json['roles']
      @rhlogin = json['username']
    end
  end

  def establish_terms
    terms
  end

  def terms
    @terms ||= http_post(@@unacknowledged_terms_url) do |json|
      json['unacknowledgedTerms'] || []
    end
  end

  def roles
    unless @initialized_roles
      old_rhlogin = @rhlogin
      establish
      raise "Authenticated user #{old_rhlogin} does not match #{@rhlogin}" unless old_rhlogin.nil? || old_rhlogin == rhlogin
    end
    @roles
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

  # Clears the current ticket and authenticates with streamline
  def authenticate(login, password)
    @ticket = nil
    Rails.logger.debug 'authenticated user'
    http_post(@@login_url, {:login => login, :password => password})
    @rhlogin = login
    true
  rescue AccessDeniedException
    errors.add(:base, I18n.t(:login_error, :scope => :streamline))
    false
  rescue Streamline::StreamlineException
    errors.add(:base, I18n.t(:service_error, :scope => :streamline))
    false
  end

  # Return a valid single signon cookie
  def streamline_cookie
    Cookie.new :rh_sso, @ticket, {
      :secure => true,
      :path => '/',
      :domain => '.redhat.com'
    } if @ticket
  end

  def accept_terms
    Rails.logger.debug("Calling streamline to accept terms")
    errors.clear
    unless terms.empty?
      http_post(build_terms_url(terms), {}, false) do |json|
        # Log error on unknown result
        Rails.logger.error("Streamline accept terms failed") unless json['term']
  
        # Unless everything was accepted, put an error on the user object
        json['term'] ||= []

        # Convert the accepted ids to strings to comparison
        # normally they are integers
        terms_ids = @terms.map{|hash| hash['termId'].to_s}
        if (terms_ids - json['term']).empty?
          @terms.clear
        else
          Rails.logger.error("Streamline partial terms acceptance. Expected #{terms_ids} got #{json['term']}")
          errors.add(:base, I18n.t(:terms_error, :scope => :streamline))
        end
      end
    end
    errors.empty?
  end
 
  # 
  # When invoked with no arguments behaves like an ActiveModel call to save the resource with
  # an updated password, assuming  @old_password, @password, and @password_confirmation are 
  # all set. Will invoke 'valid? :change_password' on the resource to ensure that validations
  # are called.  The return value is true if successful and errors are set.
  #
  def change_password(args=nil)
    if args.nil?
      if valid? :change_password
        args = {
          'oldPassword' => @old_password,
          'newPassword' => @password,
          'newPasswordConfirmation' => @password_confirmation
        }
        http_post(@@change_password_url, args) do |json|
          if json['errors']
            field = :password
            if json['errors'].include? 'password_incorrect'
              msg = 'Your old password was incorrect'
              field = :old_password
            elsif json['errors'].include? 'password_invalid'
              msg = 'Please choose a valid new password'
            else
              msg = 'Your password could not be changed'
            end
            errors.add(field, msg)
          end
          errors.empty?
        end
      end
    else
      # <b>DEPRECATED</b> Will be removed
      http_post(@@change_password_url, args) do |json|
        return json
      end
    end
  end

  #
  # When called with a single string argument behaves like an ActiveModel call to 
  # save the resource.  It will use the @email_address instance variable and invoke
  # 'valid? :reset_password' to ensure validations are called.  The return value is
  # true if successful and errors are set.
  def request_password_reset(args)
    if args.is_a? String
      if valid? :reset_password
        args = {
          :login => @email_address,
          :url => args
        }
        http_post(@@request_password_reset_url, args, false) do |json|
          Rails.logger.debug "Password reset request #{json.inspect}"
          if json['errors']
            errors.add(:base, I18n.t(:service_error, :scope => :streamline))
          end
        end
        errors.empty?
      end
    else
      http_post(@@request_password_reset_url, args, false) do |json|
        return json
      end
    end
  end

  def reset_password(args)
    http_post(@@reset_password_url, args) do |json|
      return json
    end
  end

  def complete_reset_password(token)
    args = {
      :login => @email_address,
      :token => token
    }
    http_post(@@reset_password_url, args, false) do |json|
      Rails.logger.debug "Password reset completion #{json.inspect}"
      if json['errors']
        raise TokenExpired if 'token_is_invalid' == json['errors'].first
        errors.add(:base, I18n.t(:unknown)) if errors.empty?
      end
    end
    errors.empty?
  end

  def check_access
    unless roles.index('cloud_access_1')
      if roles.index('cloud_access_request_1')
        raise Streamline::UserValidationException.new(146), "Found valid credentials but you haven't been granted access yet", caller[0..5]
      else
        raise Streamline::UserValidationException.new(147), "Found valid credentials but you haven't requested access yet", caller[0..5]
      end
    end
  end

  #
  # Register a new streamline user
  #
  def register(confirm_url)
    register_args = {'emailAddress' => @email_address,
                     'password' => @password,
                     'passwordConfirmation' => @password,
                     'secretKey' => Rails.configuration.streamline[:register_secret],
                     'termsAccepted' => 'true',
                     'confirmationUrl' => confirm_url}

    http_post(@@register_url, register_args, false) do |json|
      Rails.logger.debug "Registration response #{json.inspect}"
      if json['emailAddress']
        @email_address = json['emailAddress']
      else
        if errors.length == 0
          errors.add(:base, I18n.t(:unknown))
        end
      end
    end
    errors.empty?
  end

  def confirm_email(key,email=@email_address)
    raise "No email address provided" unless email
    confirm_args = {
      :emailAddress => email,
      :key => key
    }
    errors.clear
    http_post(@@email_confirm_url, confirm_args, false) do |json|
      Rails.logger.debug "Confirmation response #{json.inspect}"
      if json['emailAddress']
        # success
      elsif json['errors'] and json['errors'][0] == 'user_already_registered'
        # success
        errors.clear
      else
        if errors.length == 0
          errors.add(:base, I18n.t(:unknown))
        end
      end
    end
    errors.empty?
  end

  #
  # Request access to a cloud solution
  #<b>DEPRECATED</b>: Use entitled?
  def request_access(solution)
    if has_requested?(solution)
      Rails.logger.warn("User already requested access")
      errors.add(:base, I18n.t(:already_requested_access, :scope => :streamline))
    elsif has_access?(solution)
      Rails.logger.warn("User already granted access")
      errors.add(:base, I18n.t(:already_granted_access, :scope => :streamline))
    else
      access_args = {'solution' => solution}
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
                        'secretKey' => Rails.configuration.streamline[:user_info_secret]}
      http_post(@@user_info_url, user_info_args) do |json|
        @email_address = json['emailAddress']
      end
    end
  end

  #
  # Whether the user is authorized for a given cloud solution
  #<b>DEPRECATED</b>: Use entitled?
  def has_access?(solution)
    @roles.nil? ? false : @roles.index(CloudAccess.auth_role(solution)) != nil
  end

  #
  # Whether the user has already requested access for a given cloud solution
  #
  #<b>DEPRECATED</b>: Use waiting_for_entitle?
  def has_requested?(solution)
    @roles.nil? ? false : @roles.index(CloudAccess.req_role(solution)) != nil
  end

  # Return true if the user has access to OpenShift, and false if they are not yet
  # granted.  If false is returned call waiting_for_entitlement?  Will attempt to
  # request access if the user has never requested it.
  def entitled?    
    return true if roles.include?('cloud_access_1')
    
    if roles.include?('cloud_access_request_1')
      false
    else
      http_post(@@request_access_url, {'solution' => CloudAccess::EXPRESS}, false) do |json|
        if json['solution']
          refresh_roles(true)
          true
        else
          false
        end
      end
    end
  end

  # Return true if the user is currently waiting to be entitled.  No side effects
  def waiting_for_entitle?
    not roles.include?('cloud_access_1') and roles.include?('cloud_access_request_1')
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

      # Add timing code
      start_time = Time.now
      res = http.start {|http| http.request(req)}
      end_time = Time.now
      Rails.logger.debug "Response from Streamline took (#{url.path}): #{(end_time - start_time)*1000} ms"

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        Rails.logger.debug("POST Response code = #{res.code}")

        # Set the rh_sso cookie as the ticket
        parse_ticket(res.get_fields('Set-Cookie'))

        # Parse and yield the body if a block is supplied
        if res.body and !res.body.empty?
          json = parse_body(res.body)
          yield json if block_given?
        else
          Rails.logger.error "Empty response from streamline - #{res.code}"
          if raise_exception_on_error
            raise Streamline::StreamlineException
          else
            errors.add(:base, I18n.t(:unknown))
          end
        end
      when Net::HTTPForbidden, Net::HTTPUnauthorized
        Rails.logger.error "Streamline rejected the request - #{res.code}"
        Rails.logger.error "Response body:\n#{res.body}"
        raise AccessDeniedException
      else
        Rails.logger.error "Invalid HTTP response from streamline - #{res.code}"
        Rails.logger.error "Response body:\n#{res.body}"
        if raise_exception_on_error
          raise Streamline::StreamlineException
        else
          errors.add(:base, I18n.t(:unknown))
        end
      end
    rescue AccessDeniedException, Streamline::UserValidationException, Streamline::StreamlineException
      raise
    rescue Exception => e
      Rails.logger.error "Exception occurred while calling streamline - #{e.message}"
      Rails.logger.error e, e.backtrace
      if raise_exception_on_error
        raise Streamline::StreamlineException
      else
        errors.add(:base, I18n.t(:unknown))
      end
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
