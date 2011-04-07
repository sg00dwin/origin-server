require 'net/http'
require 'net/https'
require 'uri'

class Access::Flex
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :ec2AccountNumber
  
  validates_format_of :ec2AccountNumber, :with => /\d{4}-\d{4}-\d{4}/, :message => 'Account numbers are a 12 digit number separated by - Ex: 1234-1234-1234'

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
  
end
