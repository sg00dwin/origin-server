class KeyValidator < ActiveModel::Validator
  def validate(record)
    if !record.content
      record.errors.add(attribute, {:message => "Key content is required", :exit_code => 108})
    end
    if !(record.content=~ /\A[A-Za-z0-9\+\/=]+\z/)
      record.errors.add(attribute, {:message => "Invalid key content: #{record.content}", :exit_code => 108})
    end
    if !record.name
      record.errors.add(attribute, {:message => "Key name is required", :exit_code => 117})
    end
    if !(record.name =~ /\A[A-Za-z0-9]+\z/)
      record.errors.add(attribute, {:message => "Invalid key name: #{record.name }", :exit_code => 117})
    end
    if !record.type
      record.errors.add(attribute, {:message => "Key type is required", :exit_code => 116})
    end
    if !(record.type =~ /^(ssh-rsa|ssh-dss)$/)
      record.errors.add(attribute, {:message => "Invalid key type: #{record.type}", :exit_code => 116})
    end
  end
end