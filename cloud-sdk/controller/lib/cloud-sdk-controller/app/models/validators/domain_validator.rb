class DomainValidator < ActiveModel::Validator
  NAMESPACE_MAX_LENGTH = 16
  NAMESPACE_MIN_LENGTH = 1
  def validate(record)
    attributes.each do |attribute|
      value = record.read_attribute_for_validation(attribute)
      next if (value.nil? && options[:allow_nil]) || (value.blank? && options[:allow_blank])
      validate_each(record, attribute, value)
    end
  end

  def validate_each(record, attribute, val)
    Rails.logger.debug "*************Validating namespace"
    if val.nil?
      record.errors.add(attribute, {:message => "Namespace is required", :exit_code => 106})
    end
    if !(val =~ /\A[A-Za-z0-9]+\z/)
      record.errors.add(attribute, {:message => "Invalid namespace: #{val}", :exit_code => 106})
    end
    if val and val.length > NAMESPACE_MAX_LENGTH
      record.errors.add(attribute, {:message => "Namespace (#{val}) is too long.  Maximum length is #{NAMESPACE_MAX_LENGTH} characters", :exit_code => 106})
    end
    if val and val.length < NAMESPACE_MIN_LENGTH
      record.errors.add(attribute, {:message => "Namespace (#{val}) is too short.  Minimum length is #{NAMESPACE_MIN_LENGTH} characters", :exit_code => 106})
    end
    if Cloud::Sdk::ApplicationContainerProxy.blacklisted? val
      record.errors.add(attribute, {:message => "Namespace (#{val}) is not allowed.  Please choose another.", :exit_code => 106})
    end
  end
end