class WebUser < Streamline::User
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  require_dependency 'streamline/mock'
  include Streamline::Mock unless Rails.configuration.integrated

  # Helper to allow mulitple :on scopes to validators
  def self.on_scopes(*scopes)
    scopes = scopes + [:create, :update, nil] if scopes.include? :save
    lambda { |o| scopes.include?(o.validation_context) }
  end

  attr_accessor :password, :cloud_access_choice, :promo_code

  # temporary variables that are not persisted
  attr_accessor :token, :old_password

  validates :login, 
            :presence => true,
            :if => on_scopes(:reset_password)

  validates_format_of :email_address,
                      :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i,
                      :message => 'Invalid email address',
                      :if => on_scopes(:save)

  # Requires Ruby 1.9 for lookbehind
  #validates_format_of :email_address,
  #                    :with => /(?<!(ir|cu|kp|sd|sy))$/i,
  #                    :message => 'We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy'

  validates_each :email_address, :if => on_scopes(:save) do |record, attr, value|
    if value =~ /\.(ir|cu|kp|sd|sy)$/i
      record.errors.add attr, 'We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy'
    end
  end

  validates_length_of :password,
                      :minimum => 6,
                      :message => 'Passwords must be at least 6 characters',
                      :if => on_scopes(:save, :change_password)

  validates_confirmation_of :password,
                            :message => 'Passwords must match',
                            :if => on_scopes(:save, :change_password)

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

  def accepted_terms?
    terms && terms.empty?
  end

  def cache_key
    rhlogin
  end

  #
  # Lookup a user by the SSO ticket
  #
  def self.find_by_ticket(ticket)
    user = WebUser.new(:ticket => ticket)
    user.establish

    raise AccessDeniedException, "User not available by ticket" unless user.rhlogin
    user
  end

  private
    def mass_assign_attributes(attributes, protect=true)
      attributes.each do |name, value|
        next if protect && [:rhlogin, :login, :password,
                 :ticket, :roles, :terms,
                 :streamline_type, :email_address].include?(name.to_sym)
        send("#{name}=", value)
      end
    end

end
