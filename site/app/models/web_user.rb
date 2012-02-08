require 'streamline'

class WebUser
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  # Include the correct streamline implementation
  if Rails.configuration.integrated
    include Streamline
  else
    include StreamlineMock
  end

  # Helper to allow mulitple :on scopes to validators
  def self.on_scopes(*scopes)
    scopes = scopes + [:create, :update, nil] if scopes.include? :save
    lambda { |o| scopes.include?(o.validation_context) }
  end

  attr_accessor :email_address, :password, :cloud_access_choice, :promo_code

  # temporary variables that are not persisted
  attr_accessor :token, :old_password

  # expose the rhlogin field as login
  alias :login :rhlogin

  validates_format_of :email_address,
                      :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i,
                      :message => 'Invalid email address',
                      :if => on_scopes(:save, :reset_password)

  # Requires Ruby 1.9 for lookbehind
  #validates_format_of :email_address,
  #                    :with => /(?<!(ir|cu|kp|sd|sy))$/i,
  #                    :message => 'We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy'

  validates_each :email_address, :if => on_scopes(:save, :reset_password) do |record, attr, value|
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

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end

    # Make sure to initialize the array values
    @roles ||= []
  end

  def self.from_json(json)
    WebUser.new(ActiveSupport::JSON::decode(json))
  end

  def persisted?
    false
  end

  #
  # Lookup a user by the SSO ticket
  #
  def self.find_by_ticket(ticket)
    user = WebUser.new(:ticket => ticket)
    user.establish

    if user.rhlogin
      return user
    else
      return nil
    end
  end
end
