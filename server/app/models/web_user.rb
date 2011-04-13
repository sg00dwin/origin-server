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

  attr_accessor :email_address, :password, :terms_accepted

  validates_format_of :email_address,
                      :with => /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i,
                      :message => 'Invalid email address'
  
  # Requires Ruby 1.9 for lookbehind
  #validates_format_of :email_address,
  #                    :with => /(?<!(ir|cu|kp|sd|sy))$/i,
  #                    :message => 'We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy'
                      
  validates_each :email_address do |record, attr, value|
    if value =~ /\.(ir|cu|kp|sd|sy)$/i
      record.errors.add attr, 'We can not accept emails from the following top level domains: .ir, .cu, .kp, .sd, .sy'
    end
  end

  validates_length_of :password,
                      :minimum => 6,
                      :message => 'Passwords must be at least 6 characters'
                      
  validates_confirmation_of :password,
                            :message => 'Passwords must match'  

  validates_each :terms_accepted do |record, attr, value|
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
