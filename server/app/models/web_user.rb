require 'net/http'
require 'net/https'
require 'uri'

class WebUser
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :emailAddress, :password, :passwordConfirmation, :termsAccepted, :ticket, :roles

  validates_format_of :emailAddress, :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i, :message => 'Invalid email address'
  validates_length_of :password, :minimum => 6, :message => 'Passwords must be at least 6 characters'

  validates_each :termsAccepted do |record, attr, value|
    record.errors.add attr, 'Terms must be accepted' if value != '1'
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def self.from_json(json)
    WebUser.new(ActiveSupport::JSON::decode(json))
  end

  def persisted?
    false
  end

  def self.find_by_ticket(ticket)
    user = WebUser.new(:ticket => ticket)
    user.establish
    return user
  end

  #
  # Register a new streamline user
  #
  def register(confirm_url)
    # First do the authentication
    register_args = {'emailAddress' => @emailAddress,
                     'password' => @password,
                     'passwordConfirmation' => @password,
                     'secretKey' => Rails.configuration.streamline_secret,
                     'termsAccepted' => 'true',
                     'confirmationUrl' => confirm_url}

    http_post(Streamline.register_url, register_args) do |json|
      unless json['emailAddress']
        errors[:unknown] = I18n.t('unknown')
      end
    end
  end


  #
  # Login the current user, setting the roles and ticket
  #
  def login
    # First do the authentication
    login_args = {'login' => @emailAddress,
                  'password' => @password,
                  'redirectUrl' => '/noop'}

    http_post(Streamline.login_url, login_args)

    # Now retrieve the authorization roles
    http_post(Streamline.roles_url) do |json_res|
      # Verify the email address is ours
      if @emailAddress == json_res['username']
        @roles = json_res['roles']
      else
        # We had a ticket collision - do not proceed
        Rails.logger.error("Ticket collision - #{@ticket}")
        raise_client_error
      end
    end
  end

  #
  # Establish the current user based on a ticket
  #
  def establish
    http_post(Streamline.roles_url) do |json_res|
      @emailAddress = json_res['username']
      @roles = json_res['roles']
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
      http_post(Streamline.request_access_url, access_args)
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



  private



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
        Libra.client_debug "Problem with server. Response code was #{res.code}"
      end
    rescue Exception => e
      raise_client_error(e)
    end
  end

  def raise_client_error(e=nil)
      Libra.logger_debug e if e
      Libra.client_debug e if e
      # TODO - Fix this
      raise UserValidationException.new(144), I18n.t('client_error'), caller[0..5]
  end

  #
  # Parse the rh_sso cookie out of the headers
  # and set it as the ticket
  #
  def parse_ticket(cookies)
    cookies.each do |cookie|
      if cookie.index("rh_sso")
        @ticket = cookie.split('; ')[0].split("=")[1]
      end
    end if cookies
  end

  #
  # Parse the response body, setting errors on the
  # user object as necessary.  Returns json structure
  #
  def parse_body(body)
    if body
      json = ActiveSupport::JSON::decode(body)
      parse_json_errors(json) if json
      return json
    end
  end

  def parse_json_errors(json)
    json['errors'].each do |error|
      if Streamline::ERRORS.index(error)
        errors[error.to_sym] = I18n.t(error)
      else
        errors[:unknown] = I18n.t('unknown')
      end
    end if json['errors']
  end
end
