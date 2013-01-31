class WebUser < Streamline::Base
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  include Streamline::User

  attr_accessor :cloud_access_choice
  attr_reader :session_id, :csrf_token

  # temporary variables that are not persisted
  attr_accessor :old_password

  class << self
    alias_method :new_orig, :new

    def new(attr=nil)
      mock? ? WebUser::Mock.new_orig(attr) : new_orig(attr)
    end
    def mock?
      !Rails.configuration.integrated
    end
  end
  def mock?
    self.class.mock?
  end

  def initialize(attributes = nil)
    mass_assign_attributes(attributes, false) if attributes
  end

  def assign_attributes(attributes)
    mass_assign_attributes(attributes)
  end

  def self.from_json(json)
    WebUser.new(ActiveSupport::JSON::decode(json))
  end

  def persisted?
    false
  end

  def type
    case
    when simple_user?
      :openshift
    else
      :red_hat_network
    end
  end

  def cache_key
    rhlogin
  end

  #
  # Lookup a user by the SSO ticket
  #
  def self.find_by_ticket(ticket)
    user = new(:ticket => ticket)
    user.establish

    raise AccessDeniedException, "User not available by ticket" unless user.rhlogin
    user
  end

  def self.model_name
    ActiveModel::Name.new(WebUser)
  end

  def sign_session_values(values)
    @session_key ||= Rails.configuration.session_options[:key]
    @session_secret ||= Rails.configuration.secret_token
    @broker_host ||= URI.parse(Console.config.api[:url]).host
    cookie_jar = ActionDispatch::Cookies::CookieJar.new(@session_secret, @broker_host)
    cookie_jar.permanent.signed[@session_key] = { :value => values.to_hash }
    Rack::Utils.escape(cookie_jar[@session_key])
  end

  def to_headers
    signed_session = sign_session_values({ "session_id" => @session_id, "rh_sso" => @ticket, "_csrf_token" => @csrf_token })
    {
      'Cookie' => "rh_sso=#{@ticket}; login=#{@login}; #{@session_key}=#{signed_session};",
      'X-CSRF-Token' => @csrf_token.nil? ? '' : @csrf_token
    }
  end

  protected
    attr_writer :session_id, :csrf_token

  private
    def mass_assign_attributes(attributes, protect=true)
      attributes.each do |name, value|
        next if protect && [:rhlogin, :login, :password,
                 :ticket, :roles, :terms,
                 :streamline_type, :email_address, :session_id, :csrf_token].include?(name.to_sym)
        send("#{name}=", value)
      end
    end

end

class WebUser::Mock < WebUser
  include Streamline::Mock
  undef_method :to_headers
  def self.mock?
    true
  end
end

class WebUser::Integrated < WebUser
  def self.mock?
    false
  end
end
