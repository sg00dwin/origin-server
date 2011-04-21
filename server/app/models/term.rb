class Term
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization
  extend ActiveModel::Naming

  attr_accessor :terms_accepted, :accepted_terms_list
  
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
