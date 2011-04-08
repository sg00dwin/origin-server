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

  attr_accessor :emailAddress, :password, :passwordConfirmation, :termsAccepted

  validates_format_of :emailAddress,
                      :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i,
                      :message => 'Invalid email address'

  validates_length_of :password,
                      :minimum => 6,
                      :message => 'Passwords must be at least 6 characters'

  validates_each :termsAccepted do |record, attr, value|
    record.errors.add attr, 'Terms must be accepted' if value != '1'
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end

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
