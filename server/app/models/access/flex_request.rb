class Access::FlexRequest
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :ec2_account_number, :terms_accepted
  
  validates_format_of :ec2_account_number, :with => /\d{4}-\d{4}-\d{4}/, :message => 'Account numbers are a 12 digit number separated by - Ex: 1234-1234-1234'
  
  validates_each :terms_accepted do |record, attr, value|
    record.errors.add attr, 'Terms must be accepted' if !value || value == 'off'
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
  
end
