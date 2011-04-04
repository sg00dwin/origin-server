require 'net/http'
require 'net/https'
require 'uri'

class WebUser
  include ActiveModel::Validations
  include ActiveModel::Conversion
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

  def persisted?
    false
  end

  def login
    # First do the authentication
    login_url = Rails.configuration.corp_server + '/login.html'
    login_args = {'login' => @emailAddress,
                  'password' => @password,
                  'redirectUrl' => '/noop'}

    http_post(login_url, login_args) do |res|
      @ticket = res['set-cookie'].split('; ')[0].split("=")[1]
    end

    # Now retrieve the authorization roles
    roles_url = Rails.configuration.corp_server + '/cloudVerify.html'
    http_post(roles_url) do |res|
      result = JSON.parse(res.body)
      if @emailAddress == result['username']
        @roles = result['roles']
      else
        # We had a ticket collision - do not proceed
        Rails.logger.error("Ticket collision - #{@ticket}")
        raise_client_error
      end
    end
  end

  def request_access(solution, amz_acct)
    access_url = Rails.configuration.corp_server + '/requestAccess.html'
    access_args = {'solution' => solution,
                   'amazon_account' => amz_acct}

    # Make the request for access
    http_post(access_url, access_args)
  end

  def is_auth?(solution)
    @roles.index(CloudAccess.auth_role(solution)) != nil
  end

  def has_requested?(solution)
    @roles.index(CloudAccess.req_role(solution)) != nil
  end

  private

  def http_post(url_str, args={})
    begin
      url = URI.parse(url_str)
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
        yield res if block_given?
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
    raise UserValidationException.new(144), "Error communicating with user validation system.  If the problem persists please contact Red Hat support.", caller[0..5]
  end
end
