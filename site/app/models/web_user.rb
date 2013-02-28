class WebUser < Streamline::Base
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  class << self
    alias_method :new_orig, :new

    def new(attr=nil)
      (mock? ? WebUser::Mock : WebUser::Integrated).new_orig(attr)
    end
    def mock?
      !Rails.configuration.integrated
    end
    def from_json(json)
      new(ActiveSupport::JSON::decode(json))
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

  protected
    def mass_assign_attributes(attributes, protect=true)
      attributes.each do |name, value|
        next if protect && [:rhlogin, :login, :password,
                 :ticket, :api_ticket, :roles, :terms,
                 :streamline_type, :email_address].include?(name.to_sym)
        send("#{name}=", value)
      end
    end
end

module WebUser::Methods
  extend ActiveSupport::Concern

  attr_accessor :api_ticket

  # this attribute is transient
  attr_accessor :old_password

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
    login
  end

  def self.model_name
    ActiveModel::Name.new(WebUser)
  end

  def to_headers
    if api_ticket.present?
      {'Authorization' => "Bearer #{api_ticket}"}
    else
      h = {}
      h['Cookie'] = "rh_sso=#{ticket}" if ticket.present?
      h['Authorization'] = ActionController::HttpAuthentication::Basic.encode_credentials(login, password) if login.present?
      h
    end
  end

  def logout
    Authorization.destroy(api_ticket, :as => self) if api_ticket
    self.api_ticket = nil
  rescue => e
    Rails.logger.warn "Exception in logout: #{e.message} (#{e.class})\n  #{e.backtrace.join("\n  ")}"
  ensure
    super
  end
end

class WebUser::Mock < WebUser
  include Streamline::User
  include Streamline::Mock
  include WebUser::Methods

  def self.mock?
    true
  end
  def self.model_name
    ActiveModel::Name.new(WebUser)
  end
end

class WebUser::Integrated < WebUser
  include Streamline::User
  include WebUser::Methods

  def self.mock?
    false
  end
  def self.model_name
    ActiveModel::Name.new(WebUser)
  end
end
